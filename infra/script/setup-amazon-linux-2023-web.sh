#!/bin/bash
set -euxo pipefail  # エラー時は即終了 & 実行コマンド表示 & 未定義変数エラー & パイプライン失敗を検出

###############################################################################
# グローバル設定
###############################################################################
LOGFILE="/var/log/setup-env.log"
SWAP_FILE="/swapfile"
SWAP_SIZE_MB=2048

# バージョン一覧（必要に応じて編集）
DOCKER_COMPOSE_VERSION="v2.24.5"
GO_VERSION="1.20.3"
TF_VERSION="1.4.6"
KUBECTL_VERSION="v1.26.3"
DUCKDB_VERSION="v0.10.2"

# ログファイルを常に書き込む
exec > >(tee -a "$LOGFILE") 2>&1

###############################################################################
# 関数定義
###############################################################################

function step_1_system_update {
  echo "[Step 1] システムアップデート (dnf update)"
  sudo dnf update -y
}

function step_2_swap_create {
  echo "[Step 2] swapファイル作成 or スキップ"
  if [ -f "$SWAP_FILE" ]; then
      echo "[INFO] $SWAP_FILE が既に存在します。新規作成はスキップします。"
  else
      echo "[INFO] $SWAP_FILE が存在しないため新規作成します。サイズ: ${SWAP_SIZE_MB}MB"
      sudo dd if=/dev/zero of="$SWAP_FILE" bs=1M count="$SWAP_SIZE_MB" status=progress
      sudo chmod 600 "$SWAP_FILE"
      sudo mkswap "$SWAP_FILE"
      sudo swapon "$SWAP_FILE"

      # /etc/fstab に登録（重複を避けるためチェック）
      if ! grep -q "$SWAP_FILE" /etc/fstab; then
        echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
      fi
  fi
}

function step_3_epel_repo {
  echo "[Step 3] EPELリポジトリの有効化"
  sudo dnf install -y epel-release
}

function step_4_dev_tools {
  echo "[Step 4] 開発ツール & Pythonインストール"
  sudo dnf groupinstall -y "Development Tools"
  sudo dnf install -y \
      git make wget tar which \
      python3 python3-pip python3-devel \
      openssl-devel libffi-devel \
      gzip jq npm unzip
}

function step_5_docker {
  echo "[Step 5] Dockerインストール"
  sudo dnf install -y docker
  sudo systemctl enable docker
  sudo systemctl start docker
  # docker グループに ec2-user を追加
  sudo usermod -aG docker ec2-user
}

function step_6_docker_compose {
  echo "[Step 6] Docker Compose ${DOCKER_COMPOSE_VERSION} を手動インストール"
  sudo mkdir -p /usr/libexec/docker/cli-plugins/
  sudo curl -SL \
    "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
    -o /usr/libexec/docker/cli-plugins/docker-compose
  sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
  # ログ確認用
  sudo -i -u ec2-user docker compose version || true
}

function step_7_awscli {
  echo "[Step 7] AWS CLIインストール"
  sudo dnf install -y awscli
}

function step_8_nvm_node {
  echo "[Step 8] Node.js (v18) + nvmインストール"
  sudo su - ec2-user -c "
    set -e
    echo '[nvm] インストールスクリプトを実行します'
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    if ! grep -q 'NVM_DIR' ~/.bashrc; then
      cat <<EOT >> ~/.bashrc

export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"
[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"
EOT
    fi

    source ~/.bashrc
    echo '[nvm] Node.js v18 をインストールします'
    nvm install 18
    nvm alias default 18
    echo '[nvm] インストール完了: Node.js ' \$(node -v)
  "
}

function step_9_go {
  echo "[Step 9] Goインストール (version: ${GO_VERSION})"
  curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"

  sudo tee /etc/profile.d/go.sh >/dev/null <<EOF
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin
EOF
  sudo chmod 644 /etc/profile.d/go.sh

  sudo mkdir -p /home/ec2-user/go
  sudo chown -R ec2-user:ec2-user /home/ec2-user/go
}

function step_10_rust {
  echo "[Step 10] Rustインストール (rust + cargo)"
  sudo dnf install -y rust cargo
}

function step_11_terraform {
  echo "[Step 11] Terraformインストール (手動ダウンロード) : version ${TF_VERSION}"
  cd /tmp
  curl -LO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip"
  unzip "terraform_${TF_VERSION}_linux_amd64.zip"
  sudo mv terraform /usr/local/bin/
  sudo chmod +x /usr/local/bin/terraform
  echo "Terraform version: $(terraform -version | head -n1)"
}

function step_12_kubectl {
  echo "[Step 12] kubectlインストール (必要に応じて) : version ${KUBECTL_VERSION}"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl
  echo "kubectl version: $(kubectl version --client --short || true)"
}

function step_13_minikube {
  echo "[Step 13] Minikubeインストール (必要に応じて)"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  sudo dnf install -y minikube-latest.x86_64.rpm
  rm -f minikube-latest.x86_64.rpm
  echo "Minikube version: $(minikube version || true)"
}

function step_14_ansible {
  echo "[Step 14] Ansibleインストール (pip経由)"
  sudo -i -u ec2-user bash << 'EOF'
echo "[Step 14] Ansible (pip) for ec2-user"
python3 -m pip install --user ansible
~/.local/bin/ansible --version || true
EOF
}

function setup_ssm_agent {
  echo "[Step XX] AWS IAM ロール or SSM Agent 設定 (今後の拡張用)"
  sudo dnf install -y amazon-ssm-agent
  sudo systemctl enable amazon-ssm-agent
  sudo systemctl start amazon-ssm-agent
}

function step_15_duckdb {
  echo "[Step 15] DuckDB CLI インストール : version ${DUCKDB_VERSION}"
  curl -L -o duckdb "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip"
  unzip -o duckdb -d /tmp/
  sudo mv /tmp/duckdb /usr/local/bin/duckdb
  sudo chmod +x /usr/local/bin/duckdb
  duckdb --version || true
}

function step_16_helm {
  echo "[Step 16] Helm インストール"
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  helm version || true
}

function step_17_eksctl {
  echo "[Step 17] eksctl インストール"
  curl --silent --location \
    "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
    | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  eksctl version || true
}

function step_18_github_cli {
  echo "[Step 18] GitHub CLI (gh) インストール"
  type -p yum-config-manager >/dev/null || sudo dnf install -y yum-utils
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh
  gh version || true
}

function step_19_docker_info {
  echo "[Step 19] Docker Info 出力"
  docker info || true
}

function final_message {
  echo "===== セットアップ完了！ ====="
  echo "Docker, Docker Compose, AWS CLI, Node.js (nvm), Go, Rust, Python3, Terraform, kubectl, Minikube, Ansible 等がインストールされました。"
  echo "すべてのログは ${LOGFILE} に記録されています。"
  echo "※ ec2-user で再ログイン後に 'source ~/.bashrc' すれば nvm/node/minikube 等がすぐ使えます。"
}

###############################################################################
# メイン実行：必要に応じてコメントアウト/アンコメントして順序を調整
###############################################################################
# 1. システムアップデート
step_1_system_update

# 2. EPELリポジトリが必要な場合（Ansible/Rustなどに備えて先に実行）
step_3_epel_repo

# 3. swap作成
step_2_swap_create

# 4. 開発ツール & Python
step_4_dev_tools

# 5. AWS CLI (Pythonなど依存関係整備後に)
step_7_awscli

# 6. Docker
step_5_docker

# 7. Docker Compose
step_6_docker_compose

# 8. Node.js (nvm)
step_8_nvm_node

# 9. Go
step_9_go

# 10. Rust
step_10_rust

# 11. Ansible
step_14_ansible

# 12. Terraform
step_11_terraform

# 13. kubectl
step_12_kubectl

# 14. Minikube
step_13_minikube

# 15. Helm
step_16_helm

# 16. eksctl
step_17_eksctl

# 17. DuckDB
step_15_duckdb

# 18. GitHub CLI (gh)
step_18_github_cli

# 19. Docker Info
step_19_docker_info

# XX. SSM Agent (必要に応じて)
setup_ssm_agent

final_message

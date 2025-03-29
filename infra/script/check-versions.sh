#!/bin/bash

set -euo pipefail
trap 'echo "エラーが発生しました: $?" >&2' ERR

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_command() {
    command -v "$1" &>/dev/null
}

check_versions() {
    log "インストール済みのコンポーネントバージョンを確認します..."

    #==============================
    # 🔧 開発ツール
    #==============================
    if check_command git; then
        log "Git version: $(git --version)"
    else
        log "Git: Not installed"
    fi

    if check_command make; then
        log "Make version: $(make --version | head -n1)"
    else
        log "Make: Not installed"
    fi

    if check_command python3; then
        log "Python version: $(python3 --version 2>&1)"
    else
        log "Python3: Not installed"
    fi

    if check_command pip3; then
        log "pip version: $(pip3 --version)"
    else
        log "pip3: Not installed"
    fi

    #==============================
    # 🐍 Node.js系
    #==============================
    if check_command node; then
        log "Node.js version: $(node -v)"
        log "npm version: $(npm -v)"
        if [ -s "/home/ec2-user/.nvm/nvm.sh" ]; then
            . "/home/ec2-user/.nvm/nvm.sh"
            log "nvm version: $(nvm --version)"
        else
            log "nvm: Not found in /home/ec2-user/.nvm/nvm.sh"
        fi
    else
        log "Node.js: Not installed"
    fi

    #==============================
    # 🐘 言語 / データベース
    #==============================
    if check_command go; then
        log "Go version: $(go version)"
        log "Go environment:"
        log "  GOROOT: ${GOROOT:-Not set}"
        log "  GOPATH: ${GOPATH:-Not set}"
    else
        log "Go: Not installed"
    fi

    if check_command rustc; then
        log "Rust version: $(rustc --version)"
    else
        log "Rust: Not installed"
    fi

    if check_command cargo; then
        log "Cargo version: $(cargo --version)"
    else
        log "Cargo: Not installed"
    fi

    if check_command duckdb; then
        log "DuckDB version: $(duckdb --version)"
    else
        log "DuckDB: Not installed"
    fi

    #==============================
    # 🐳 Docker関連
    #==============================
    if check_command docker; then
        log "Docker version: $(docker --version)"
        log "--- Docker Info (抜粋) ---"
        # SIGPIPE回避のため || true を追加
        docker info | head -n 10 | while read -r line; do
            log "$line"
        done || true
    else
        log "Docker: Not installed"
    fi

    if docker compose version &>/dev/null; then
        log "Docker Compose v2 version: $(docker compose version)"
    elif check_command docker-compose; then
        log "Docker Compose v1 version: $(docker-compose --version)"
    else
        log "Docker Compose: Not installed"
    fi

    #==============================
    # ☁️ AWS & CLIツール
    #==============================
    if check_command aws; then
        log "AWS CLI version: $(aws --version 2>&1)"

        log "AWS認証チェック: aws sts get-caller-identity"
        if aws sts get-caller-identity &>/dev/null; then
            aws sts get-caller-identity | while read -r line; do log "$line"; done
        else
            log "❌ AWS認証エラー（IAM未設定または認証情報に誤りがあります）"
        fi

        log "aws configure list"
        aws configure list | while read -r line; do log "$line"; done
    else
        log "AWS CLI: Not installed"
    fi

    if check_command terraform; then
        log "Terraform version: $(terraform --version | head -n1)"
    else
        log "Terraform: Not installed"
    fi

    if [ -x "/home/ec2-user/.local/bin/ansible" ]; then
        log "Ansible version: $(/home/ec2-user/.local/bin/ansible --version | head -n1)"
    elif check_command ansible; then
        log "Ansible version: $(ansible --version | head -n1)"
    else
        log "Ansible: Not installed"
    fi

    if check_command gh; then
        log "GitHub CLI (gh) version: $(gh version | head -n1)"
    else
        log "GitHub CLI (gh): Not installed"
    fi

    #==============================
    # ☸️ Kubernetes関連
    #==============================
    if check_command kubectl; then
        # JSON出力でなくともバージョン情報を一部得られる
        log "kubectl version: $(kubectl version --client 2>/dev/null | grep 'GitVersion' || echo 'Error')"
    else
        log "kubectl: Not installed"
    fi

    if check_command minikube; then
        log "Minikube version: $(minikube version 2>/dev/null | grep 'version:' || echo 'Error')"
    else
        log "Minikube: Not installed"
    fi

    if check_command helm; then
        log "Helm version: $(helm version --short 2>/dev/null || echo 'Error')"
    else
        log "Helm: Not installed"
    fi

    if check_command eksctl; then
        log "eksctl version: $(eksctl version 2>/dev/null || echo 'Error')"
    else
        log "eksctl: Not installed"
    fi

    #==============================
    # ➕ PATH補足
    #==============================
    if ! grep -q '.local/bin' /home/ec2-user/.bashrc; then
        echo 'export PATH=$PATH:$HOME/.local/bin' >> /home/ec2-user/.bashrc
        log "追加: ~/.local/bin を PATH に含めました（ec2-user）"
    fi
}

# メイン実行
check_versions

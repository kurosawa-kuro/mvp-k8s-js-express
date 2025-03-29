# 開発環境セットアップガイド

## リポジトリ参照
- [Ruby TypeScript Notes](https://github.com/kurosawa-kuro/ruby-typescript-note)
- [Wamazing Rails](https://github.com/kurosawa-kuro/wamazing-rails)

## Gitのセットアップ


# EC2でのGit環境構築手順

## 1. OSパッケージの更新とGitのインストール

### Amazon Linux 2の場合
```bash
# システムパッケージを最新に更新
sudo yum update -y

# Gitをインストール
sudo yum install git -y

# インストールされたGitのバージョンを確認
git --version
```

### Ubuntuの場合
```bash
# システムパッケージを最新に更新
sudo apt-get update

# Gitをインストール
sudo apt-get install git -y

# インストールされたGitのバージョンを確認
git --version
```

## 2. SSH鍵の設定

### 2.1 秘密鍵の設置
```bash
# 秘密鍵ファイルを作成
vi ~/.ssh/id_rsa

# 秘密鍵のパーミッションを適切に設定
chmod 600 ~/.ssh/id_rsa
```

参考：開発用SSH鍵の詳細は以下のドキュメントを参照
- https://docs.google.com/document/d/1U3DCa9kq-etObsQuWdduxmt1ZA-VadbbNzA9HadJyxc/edit?tab=t.0

## 3. Gitの初期設定

```bash
# Gitユーザー名を設定
git config --global user.name "Toshifumi Kurosawa"

# Gitメールアドレスを設定
git config --global user.email "kuromailserver@gmail.com"

# Git設定の一覧を確認
git config --list
```

## 4. GitHub接続テスト

```bash
# GitHubへのSSH接続をテスト
ssh -T git@github.com
```

この順序にした理由：
1. まずシステムの更新とGitのインストールが必要
2. 次にリモートリポジトリと通信するためのSSH設定
3. その後、Gitの基本設定を行う
4. 最後に全ての設定が正しく機能するか確認テスト

これで、Git環境の構築からGitHubとの接続確認までの一連の流れが完了します。


## 環境変数設定
```env
# アプリケーションポート
BACKEND_PORT=8000
FRONTEND_PORT=3000

# データベース接続情報
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_DB=dev_db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_DIALECT=postgres
DATABASE_SSL=false
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/dev_db

# Docker設定
DOCKER_DATABASE_HOST=db

# AWS
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=ap-northeast-1
AWS_BUCKET_NAME=your-bucket-name
AWS_CLOUDFRONT_URL=your-cloudfront-url

# Heroku
HEROKU_API_KEY=your_api_key
HEROKU_APP_NAME=your-app-name
DATABASE_URL_PROD=postgres://username:password@host:5432/database

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name

# Elasticsearch
ELASTICSEARCH_HOST=localhost
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_USERNAME=elastic
ELASTICSEARCH_PASSWORD=changeme

# メール設定
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-specific-password
MAIL_FROM=noreply@yourdomain.com

# 認証設定
JWT_SECRET_KEY=secret
NODE_ENV=development

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@admin.com
PGADMIN_DEFAULT_PASSWORD=admin
PGADMIN_PORT=5050

# アップロード設定
UPLOAD_DIR=uploads
```

## SSH設定

### EC2接続設定
```ssh-config
# EC2インスタンス1（Ubuntu）
Host ec2_1
  HostName ec2-43-207-110-40.ap-northeast-1.compute.amazonaws.com
  IdentityFile C:\Users\kuros\Downloads\Development\deployer-key.pem
  User ubuntu

# EC2インスタンス2（Amazon Linux）
Host ec2_2
  HostName ec2-43-206-107-123.ap-northeast-1.compute.amazonaws.com
  IdentityFile G:\マイドライブ\LocalWorkingSpace\ドキュメント\09_プログラム\aws\kuro.dougu1+d.pem
  User ec2-user
```

### SSHキー生成手順

1. キーの作成
```bash
# 通常用（GitHub等）
ssh-keygen -t rsa -b 4096 -C "kuromailserver@gmail.com"

# 高セキュリティ用
ssh-keygen -t ed25519 -C "kuromailserver@gmail.com"
```

2. 保存先設定
```bash
# デフォルト: ~/.ssh/id_rsa
# カスタム: ~/.ssh/任意の名前
```

3. パスフレーズ設定
```bash
# セキュリティ向上のため設定推奨
```

4. 公開キーの確認
```bash
# RSAの場合
cat ~/.ssh/id_rsa.pub

# Ed25519の場合
cat ~/.ssh/id_ed25519.pub
```

5. 権限設定
```bash
chmod 600 ~/.ssh/id_rsa     # 秘密キー
chmod 644 ~/.ssh/id_rsa.pub # 公開キー
```

### よく使うコマンド
```bash
# SSHエージェント起動
eval "$(ssh-agent -s)"

# 鍵の登録
ssh-add ~/.ssh/id_rsa

# GitHub接続確認
ssh -T git@github.com
```

```
AWS Access Key ID [None]: AKIATFBMPKX7ACCBABIB
AWS Secret Access Key [None]: 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
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

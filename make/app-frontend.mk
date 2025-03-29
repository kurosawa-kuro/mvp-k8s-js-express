# ================================
# フロントエンド開発コマンド
# ================================

# Docker設定
FRONTEND_DOCKER_USERNAME := kurosawakuro
FRONTEND_DOCKER_IMAGE := frontend-3000
FRONTEND_DOCKER_TAG := latest
FRONTEND_CONTAINER_NAME := frontend-container

# Docker完全イメージ名
FRONTEND_DOCKER_FULL_IMAGE := $(FRONTEND_DOCKER_USERNAME)/$(FRONTEND_DOCKER_IMAGE):$(FRONTEND_DOCKER_TAG)

# ================================
# 開発コマンド
# ================================

# 開発サーバー起動
frontend-dev:
	cd src/frontend && npm run dev

# ビルド実行
frontend-build:
	$(call check-command, npm)
	npm run build

# ビルド済み環境起動
frontend-start:
	$(DOCKER_COMPOSE) up -d frontend

# Lint実行
frontend-lint:
	$(call check-command, npm)
	npm run lint

# テスト実行
frontend-test:
	$(call check-command, npm)
	npm run test

# ================================
# Docker関連コマンド
# ================================

# Dockerイメージビルド
frontend-docker-build:
	cd src/frontend && docker build -t $(FRONTEND_DOCKER_FULL_IMAGE) .

# Dockerコンテナ起動
frontend-docker-run:
	cd src/frontend && docker run -p $(FRONTEND_PORT):$(FRONTEND_PORT) --name $(FRONTEND_CONTAINER_NAME) $(FRONTEND_DOCKER_FULL_IMAGE)

# バックグラウンドでコンテナ起動
frontend-docker-run-detached:
	cd src/frontend && docker run -d -p $(FRONTEND_PORT):$(FRONTEND_PORT) --name $(FRONTEND_CONTAINER_NAME) $(FRONTEND_DOCKER_FULL_IMAGE)

# DockerHubにイメージをプッシュ
frontend-docker-push-dockerhub:
	cd src/frontend && docker push $(FRONTEND_DOCKER_FULL_IMAGE)

# ECRにイメージをプッシュ
frontend-docker-push-ecr:
	cd src/frontend && docker push $(ECR_FULL_IMAGE)

# コンテナ停止と削除
frontend-docker-stop:
	$(DOCKER_COMPOSE) down frontend

# コンテナログ確認
frontend-docker-logs:
	$(DOCKER_COMPOSE) logs -f frontend

# コンテナシェルアクセス
frontend-docker-shell:
	$(DOCKER_COMPOSE) exec frontend sh

# ================================
# 便利機能
# ================================

# イメージビルドとDockerHubプッシュ
frontend-deploy: frontend-docker-build frontend-docker-push-dockerhub

# イメージビルドとコンテナ起動（一括実行）
frontend-docker-all: frontend-docker-build frontend-docker-run
	@echo "フロントエンドコンテナを起動しました。ブラウザで http://localhost:$(FRONTEND_PORT) にアクセスしてください"

# フロントエンドアプリケーション関連のターゲット
.PHONY: frontend-build frontend-start frontend-stop frontend-test frontend-lint
.PHONY: frontend-install frontend-clean frontend-shell frontend-logs

# インストール関連
frontend-install:
	$(call check-command, npm)
	npm install

frontend-clean:
	rm -rf .next
	rm -rf node_modules
	rm -rf .cache

# 開発関連
frontend-shell:
	$(DOCKER_COMPOSE) exec frontend sh

frontend-logs:
	$(DOCKER_COMPOSE) logs -f frontend


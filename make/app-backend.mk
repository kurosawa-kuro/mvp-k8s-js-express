# ================================
# バックエンド開発コマンド
# ================================

# Docker設定
BACKEND_DOCKER_USERNAME := kurosawakuro
BACKEND_DOCKER_IMAGE := backend-8080
BACKEND_DOCKER_TAG := latest
BACKEND_CONTAINER_NAME := backend-container
BACKEND_PORT := 8080

# Docker完全イメージ名
BACKEND_DOCKER_FULL_IMAGE := $(BACKEND_DOCKER_USERNAME)/$(BACKEND_DOCKER_IMAGE):$(BACKEND_DOCKER_TAG)

# ECR設定
ECR_REPO := 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/backend-8080
ECR_TAG ?= $(BACKEND_DOCKER_TAG)
ECR_FULL_IMAGE := $(ECR_REPO):$(ECR_TAG)

# ================================
# 開発コマンド
# ================================

# 開発サーバー起動
backend-dev:
	cd src/backend && GO_ENV=dev go run main.go

# 依存関係整理
backend-mod-tidy:
	cd src/backend && go mod tidy

# APIテスト実行
backend-test:
	$(call check-command, go)
	go test ./src/backend/... -v

# 本番環境APIテスト
backend-test-prod:
	curl http://localhost:$(BACKEND_PORT)/api/health
	curl http://localhost:$(BACKEND_PORT)/api/v1/ping

# ================================
# Docker関連コマンド
# ================================

# Dockerイメージビルド
backend-docker-build:
	cd src/backend && docker build -t $(BACKEND_DOCKER_FULL_IMAGE) .

# Dockerコンテナ起動
backend-docker-run:
	cd src/backend && docker run -p $(BACKEND_PORT):$(BACKEND_PORT) --name $(BACKEND_CONTAINER_NAME) $(BACKEND_DOCKER_FULL_IMAGE)

# DockerHubにプッシュ
backend-docker-push-dockerhub:
	cd src/backend && docker push $(BACKEND_DOCKER_FULL_IMAGE)

# ECRにプッシュ
backend-docker-push-ecr:
	cd src/backend && docker push $(ECR_FULL_IMAGE)

# コンテナ停止と削除（エラーを無視）
backend-docker-stop:
	-docker stop $(BACKEND_CONTAINER_NAME) 2>/dev/null || true
	-docker rm $(BACKEND_CONTAINER_NAME) 2>/dev/null || true

# コンテナログ確認
backend-docker-logs:
	docker logs $(BACKEND_CONTAINER_NAME)

# コンテナシェルアクセス
backend-docker-shell:
	docker exec -it $(BACKEND_CONTAINER_NAME) /bin/sh

# ================================
# 便利機能
# ================================

# イメージビルドとDockerHubプッシュ（既存コンテナを停止してから実行）
backend-deploy: backend-docker-stop backend-docker-build backend-docker-push-dockerhub

# イメージビルドとコンテナ起動（一括実行、既存コンテナを停止してから実行）
backend-docker-all: backend-docker-stop backend-docker-build backend-docker-run
	@echo "バックエンドコンテナを起動しました。テストするには 'make backend-test' を実行してください"

# バックエンドアプリケーション関連のターゲット
.PHONY: backend-build backend-start backend-stop backend-lint
.PHONY: backend-migrate backend-seed backend-shell backend-logs

# ビルド関連
backend-build:
	$(call check-command, go)
	go build -o bin/backend ./src/backend

backend-start:
	$(DOCKER_COMPOSE) up -d backend

backend-stop:
	$(DOCKER_COMPOSE) down backend

# テスト関連
backend-lint:
	$(call check-command, golangci-lint)
	golangci-lint run ./src/backend/...

# データベース関連
backend-migrate:
	$(call check-command, migrate)
	migrate -path migrations -database "$(DATABASE_URL)" up

backend-seed:
	$(call check-command, go)
	go run scripts/seed.go

# 開発関連
backend-shell:
	$(DOCKER_COMPOSE) exec backend sh

backend-logs:
	$(DOCKER_COMPOSE) logs -f backend 
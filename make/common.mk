# 重複読み込みを防ぐ
ifdef COMMON_MK_INCLUDED
$(error common.mk is already included)
endif
COMMON_MK_INCLUDED := 1

# 環境変数の読み込み
ENV_FILE := $(shell pwd)/.env
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# デフォルト値の設定
NODE_VERSION ?= 18
PYTHON_VERSION ?= 3.11
APP_NAME ?= template-web
VERSION ?= 1.0.0

# データベース設定のデフォルト値
DB_HOST ?= localhost
DB_PORT ?= 5432
DB_NAME ?= template_web
DB_USER ?= postgres
DB_PASSWORD ?= postgres
DATABASE_URL ?= postgresql://postgres:postgres@localhost:5432/template_web

# アプリケーションポートのデフォルト値
BACKEND_PORT ?= 8080
FRONTEND_PORT ?= 3000

# AWS設定のデフォルト値
AWS_REGION ?= ap-northeast-1
AWS_PROFILE ?= default
ECR_REPO ?= 123456789012.dkr.ecr.ap-northeast-1.amazonaws.com/template-web

# モニタリング設定のデフォルト値
FUNCTION_NAME ?= template-web-function
DASHBOARD_NAME ?= template-web-dashboard
START_TIME ?= $(shell date -d "1 hour ago" +%Y-%m-%dT%H:%M:%S)
END_TIME ?= $(shell date +%Y-%m-%dT%H:%M:%S)

# セキュリティ設定のデフォルト値
TARGET_URL ?= http://localhost:8080
JWT_SECRET_KEY ?= your-secret-key-here

# 開発環境設定のデフォルト値
NODE_ENV ?= development
UPLOAD_DIR ?= uploads
NEXT_PUBLIC_ASSET_PREFIX ?= http://localhost:3000

# Docker設定
DOCKER_COMPOSE = docker-compose

# ユーティリティ関数
define check-command
    @if ! command -v $(1) &> /dev/null; then \
        echo "Error: $(1) is not installed"; \
        exit 1; \
    fi
endef

# 共通のクリーンアップターゲット
.PHONY: clean
clean:
	rm -rf node_modules
	rm -rf .venv
	rm -rf dist
	rm -rf build
	rm -rf .coverage
	rm -rf __pycache__
	rm -rf .pytest_cache

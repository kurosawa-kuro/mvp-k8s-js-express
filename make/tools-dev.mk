# ================================
# 開発環境関連のターゲット
# ================================

# 開発環境関連のターゲット
.PHONY: dev-setup dev-install dev-clean dev-config
.PHONY: dev-up dev-down dev-logs dev-shell
.PHONY: dev-kill-ports dev-disk-usage

# セットアップ関連
dev-setup:
	$(call check-command, node)
	nvm install $(NODE_VERSION)
	nvm use $(NODE_VERSION)

dev-install:
	$(call check-command, npm)
	npm install
	pip install -r requirements.txt

dev-clean:
	rm -rf node_modules
	rm -rf .venv
	rm -rf dist
	rm -rf build

dev-config:
	cp .env.example .env
	cp docker-compose.example.yml docker-compose.yml

# Docker関連
dev-up:
	$(call check-command, docker-compose)
	$(DOCKER_COMPOSE) up -d

dev-down:
	$(call check-command, docker-compose)
	$(DOCKER_COMPOSE) down

dev-logs:
	$(call check-command, docker-compose)
	$(DOCKER_COMPOSE) logs -f

dev-shell:
	$(call check-command, docker-compose)
	$(DOCKER_COMPOSE) exec app sh

# ポート管理
dev-kill-ports:
	@echo "ポート3000と8080を終了します..."
	@if command -v fuser >/dev/null 2>&1; then \
		sudo fuser -k 3000/tcp 2>/dev/null || true; \
		sudo fuser -k 8080/tcp 2>/dev/null || true; \
		echo "ポートを終了しました"; \
	else \
		echo "fuserコマンドが見つかりません。sudo apt-get install psmisc でインストールしてください。"; \
		exit 1; \
	fi

# システム情報
dev-disk-usage:
	@echo "ディスク使用状況を確認します..."
	@df -h

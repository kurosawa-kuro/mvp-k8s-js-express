# ================================
# メインMakefile
# ================================

# メインMakefileのディレクトリ
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# デバッグ出力 MAKEFILE_DIR
@echo "MAKEFILE_DIR: $(MAKEFILE_DIR)"

# サブMakefileの読み込み
include make/common.mk
include make/app-frontend.mk
include make/app-backend.mk
include make/infra-aws.mk
include make/tools-curl.mk
include make/tools-db.mk
include make/tools-test.mk
include make/tools-ci.mk
include make/tools-docs.mk
include make/tools-security.mk
include make/tools-dev.mk
include make/tools-monitoring.mk

# ================================
# ヘルプコマンド
# ================================

# デフォルトのターゲット
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "利用可能なコマンド:"
	@echo "  開発環境:"
	@echo "    make dev-setup      - 開発環境のセットアップ"
	@echo "    make dev-install    - 依存関係のインストール"
	@echo "    make dev-up         - 開発環境の起動"
	@echo "    make dev-down       - 開発環境の停止"
	@echo ""
	@echo "  バックエンド:"
	@echo "    make backend-dev    - バックエンド開発サーバー起動"
	@echo "    make backend-test   - バックエンドテスト実行"
	@echo "    make backend-build  - バックエンドビルド"
	@echo ""
	@echo "  フロントエンド:"
	@echo "    make frontend-dev   - フロントエンド開発サーバー起動"
	@echo "    make frontend-test  - フロントエンドテスト実行"
	@echo "    make frontend-build - フロントエンドビルド"
	@echo ""
	@echo "  データベース:"
	@echo "    make db-migrate     - データベースマイグレーション"
	@echo "    make db-seed        - シードデータ投入"
	@echo "    make db-backup      - データベースバックアップ"
	@echo ""
	@echo "  テスト:"
	@echo "    make test-unit      - ユニットテスト実行"
	@echo "    make test-integration - 統合テスト実行"
	@echo "    make test-e2e       - E2Eテスト実行"
	@echo ""
	@echo "  セキュリティ:"
	@echo "    make security-scan  - セキュリティスキャン"
	@echo "    make security-test  - セキュリティテスト"
	@echo ""
	@echo "  ドキュメント:"
	@echo "    make docs-build     - ドキュメントビルド"
	@echo "    make docs-serve     - ドキュメントサーバー起動"
	@echo ""
	@echo "  インフラ:"
	@echo "    make aws-deploy     - AWSインフラデプロイ"
	@echo "    make aws-destroy    - AWSインフラ削除"
	@echo ""
	@echo "  その他:"
	@echo "    make clean          - クリーンアップ"
	@echo "    make help           - このヘルプを表示"


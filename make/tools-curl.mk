# ================================
# APIテストコマンド
# ================================

# curlコマンド関連のターゲット
.PHONY: curl-health curl-ping curl-api curl-auth curl-upload
.PHONY: curl-download curl-benchmark curl-trace

# テスト用変数
API_HOST ?= localhost
API_PORT ?= 8080
API_BASE_URL = http://$(API_HOST):$(API_PORT)

# 基本的なヘルスチェック
curl-health:
	$(call check-command, curl)
	curl -v http://localhost:$(BACKEND_PORT)/health

# Ping APIテスト
curl-ping:
	$(call check-command, curl)
	curl -v http://localhost:$(BACKEND_PORT)/ping

# 基本APIテスト（複数エンドポイント）
curl-test: curl-health curl-ping
	@echo "基本APIテスト完了！"

# カスタムAPIテスト（パスを指定）
curl-path:
	@read -p "テストするAPIパスを入力してください: " path; \
	curl $(API_BASE_URL)/$$path

# 後方互換性のための古いコマンド
curl: curl-health
	@echo "注意：'make curl'は非推奨です。代わりに 'make curl-test' か 'make curl-health' をお使いください。"

# APIテスト関連
curl-api:
	$(call check-command, curl)
	curl -v -X GET http://localhost:$(BACKEND_PORT)/api/v1/endpoint

curl-auth:
	$(call check-command, curl)
	curl -v -X POST http://localhost:$(BACKEND_PORT)/api/v1/auth \
		-H "Content-Type: application/json" \
		-d '{"username": "test", "password": "test"}'

# ファイル操作関連
curl-upload:
	$(call check-command, curl)
	curl -v -X POST http://localhost:$(BACKEND_PORT)/api/v1/upload \
		-F "file=@test.txt"

curl-download:
	$(call check-command, curl)
	curl -v -O http://localhost:$(BACKEND_PORT)/api/v1/download/test.txt

# パフォーマンス関連
curl-benchmark:
	$(call check-command, curl)
	curl -v -w "\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTotal: %{time_total}s\n" \
		http://localhost:$(BACKEND_PORT)/api/v1/benchmark

curl-trace:
	$(call check-command, curl)
	curl -v --trace-ascii trace.txt http://localhost:$(BACKEND_PORT)/api/v1/trace 
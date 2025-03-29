# テスト関連のターゲット
.PHONY: test-unit test-integration test-e2e test-coverage
.PHONY: test-watch test-ci test-report test-clean

# テスト実行
test-unit:
	$(call check-command, npm)
	npm run test:unit

test-integration:
	$(call check-command, npm)
	npm run test:integration

test-e2e:
	$(call check-command, cypress)
	cypress run

test-coverage:
	$(call check-command, npm)
	npm run test:coverage

# 開発用テスト
test-watch:
	$(call check-command, npm)
	npm run test:watch

test-ci:
	$(call check-command, npm)
	npm run test:ci

# レポート関連
test-report:
	$(call check-command, npm)
	npm run test:report

test-clean:
	rm -rf coverage
	rm -rf .nyc_output
	rm -rf cypress/videos
	rm -rf cypress/screenshots

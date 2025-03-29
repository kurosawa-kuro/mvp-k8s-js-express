# CI/CD関連のターゲット
.PHONY: ci-build ci-test ci-deploy ci-clean
.PHONY: ci-lint ci-security ci-docs ci-release

# ビルド関連
ci-build:
	$(call check-command, docker)
	docker build -t $(APP_NAME):$(VERSION) .

ci-test:
	$(MAKE) test-unit
	$(MAKE) test-integration

ci-deploy:
	$(call check-command, aws)
	aws ecr push $(APP_NAME):$(VERSION)

ci-clean:
	docker system prune -f

# 品質チェック
ci-lint:
	$(call check-command, npm)
	npm run lint
	$(call check-command, golangci-lint)
	golangci-lint run

ci-security:
	$(call check-command, npm)
	npm audit
	$(call check-command, snyk)
	snyk test

ci-docs:
	$(call check-command, mkdocs)
	mkdocs build

# リリース関連
ci-release:
	$(call check-command, gh)
	gh release create v$(VERSION) --title "Release v$(VERSION)" --notes "Release notes for v$(VERSION)"

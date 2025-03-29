# ドキュメント関連のターゲット
.PHONY: docs-api docs-arch docs-changelog docs-build
.PHONY: docs-serve docs-clean docs-validate docs-deploy

# APIドキュメント
docs-api:
	$(call check-command, swagger-cli)
	swagger-cli bundle api/swagger.yaml -o docs/api.json

docs-arch:
	$(call check-command, plantuml)
	plantuml docs/architecture/*.puml

# 変更履歴
docs-changelog:
	$(call check-command, conventional-changelog)
	conventional-changelog -p angular -i CHANGELOG.md -s

# ビルド関連
docs-build:
	$(call check-command, mkdocs)
	mkdocs build

docs-serve:
	$(call check-command, mkdocs)
	mkdocs serve

docs-clean:
	rm -rf site
	rm -rf docs/_build

# 検証関連
docs-validate:
	$(call check-command, markdownlint)
	markdownlint docs/**/*.md

# デプロイ関連
docs-deploy:
	$(call check-command, mkdocs)
	mkdocs gh-deploy

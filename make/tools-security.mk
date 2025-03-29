# セキュリティ関連のターゲット
.PHONY: security-scan security-test security-compliance security-verify
.PHONY: security-audit security-update security-report security-clean

# スキャン関連
security-scan:
	$(call check-command, npm)
	npm audit

security-test:
	$(call check-command, owasp-zap-cli)
	owasp-zap-cli quick-scan --self-contained --start-options "-config api.disablekey=true" $(TARGET_URL)

security-compliance:
	$(call check-command, checkov)
	checkov -d .

security-verify:
	$(call check-command, snyk)
	snyk test

# 監査関連
security-audit:
	$(call check-command, npm)
	npm audit fix

security-update:
	$(call check-command, npm)
	npm update

# レポート関連
security-report:
	$(call check-command, npm)
	npm audit --json > security-report.json

security-clean:
	rm -rf security-report.json
	rm -rf .snyk
	rm -rf .zap

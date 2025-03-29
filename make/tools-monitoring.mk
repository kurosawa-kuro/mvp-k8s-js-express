# ================================
# モニタリング関連のターゲット
# ================================

# モニタリング関連のターゲット
.PHONY: monitoring-logs monitoring-metrics monitoring-alerts monitoring-report
.PHONY: monitoring-dashboard monitoring-clean monitoring-export
.PHONY: monitoring-logs-file monitoring-logs-system

# ログ関連
monitoring-logs:
	$(call check-command, aws)
	aws logs tail /aws/lambda/$(FUNCTION_NAME) --follow

monitoring-metrics:
	$(call check-command, aws)
	aws cloudwatch get-metric-statistics \
		--namespace AWS/Lambda \
		--metric-name Invocations \
		--dimensions Name=FunctionName,Value=$(FUNCTION_NAME) \
		--start-time $(START_TIME) \
		--end-time $(END_TIME) \
		--period 3600 \
		--statistics Sum

monitoring-alerts:
	$(call check-command, aws)
	aws cloudwatch describe-alerts

# レポート関連
monitoring-report:
	$(call check-command, aws)
	aws cloudwatch get-metric-data \
		--metric-data-queries file://monitoring/metrics.json

monitoring-dashboard:
	$(call check-command, aws)
	aws cloudwatch get-dashboard \
		--dashboard-name $(DASHBOARD_NAME)

# エクスポート関連
monitoring-export:
	$(call check-command, aws)
	aws cloudwatch get-metric-data \
		--metric-data-queries file://monitoring/metrics.json \
		--output json > monitoring/export_$(shell date +%Y%m%d).json

monitoring-clean:
	rm -rf monitoring/export_*.json
	rm -rf monitoring/reports

# システムログ関連
monitoring-logs-file:
	@echo "環境セットアップログを確認します..."
	@if [ -f /var/log/setup-env.log ]; then \
		cat /var/log/setup-env.log; \
	else \
		echo "ログファイルが見つかりません: /var/log/setup-env.log"; \
		exit 1; \
	fi

monitoring-logs-system:
	@echo "システムログを確認します..."
	@if [ -f /var/log/syslog ]; then \
		tail -n 100 /var/log/syslog; \
	else \
		echo "システムログが見つかりません: /var/log/syslog"; \
		exit 1; \
	fi

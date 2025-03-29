# データベース関連のターゲット
.PHONY: db-migrate db-seed db-backup db-restore
.PHONY: db-create db-drop db-reset db-status

# マイグレーション関連
db-migrate:
	$(call check-command, prisma)
	prisma migrate deploy

db-seed:
	$(call check-command, prisma)
	prisma db seed

# バックアップ関連
db-backup:
	$(call check-command, pg_dump)
	pg_dump -h $(DB_HOST) -U $(DB_USER) $(DB_NAME) > backup_$(shell date +%Y%m%d).sql

db-restore:
	$(call check-command, psql)
	psql -h $(DB_HOST) -U $(DB_USER) $(DB_NAME) < $(BACKUP_FILE)

# データベース管理
db-create:
	$(call check-command, createdb)
	createdb -h $(DB_HOST) -U $(DB_USER) $(DB_NAME)

db-drop:
	$(call check-command, dropdb)
	dropdb -h $(DB_HOST) -U $(DB_USER) $(DB_NAME)

db-reset:
	$(MAKE) db-drop
	$(MAKE) db-create
	$(MAKE) db-migrate
	$(MAKE) db-seed

db-status:
	$(call check-command, psql)
	psql -h $(DB_HOST) -U $(DB_USER) -c "\dt" $(DB_NAME)

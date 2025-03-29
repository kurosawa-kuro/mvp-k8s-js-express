# template-web

[sample](./docs/sample.md)

AWS EC2前系
ssm反映
iam反映
amiからec2を作成
fargate環境

区分	ディレクトリ	役割
PoC	poc/	検証用コード、自由なMakefile、DB等
本番想定	src/	プロダクトコード、CI/CD対象
本番インフラ	infra/iac/	プロダクトのTerraform
PoCインフラ	infra/poc-iac/	消してもよい検証用Terraform定義
ナレッジ	docs/	マニュアル、ノウハウ、Tips

✅ 構成イメージ（あなたの意図を具体化）
bash
コピーする
編集する
src/
├── backend/
│   └── services/
│       ├── user-service/
│       │   ├── main.go
│       │   ├── handler/
│       │   ├── model/
│       │   ├── db/
│       │   ├── routes/
│       │   └── logger/
│       └── micropost-service/
│           ├── main.go
│           ├── handler/
│           ├── model/
│           ├── db/
│           ├── routes/
│           └── logger/
├── frontend/
│   └── ...（Next.js）...
└── shared/           # 任意：共通構造体・ユーティリティ
✅ 各サービスの中はこう分けると保守性◎
例：user-service/

bash
コピーする
編集する
src/
└── backend/
    └── services/
        └── user-service/
            ├── main.go                  # Gin起動 + DI
            ├── router/
            │   └── router.go            # ルーティング設定
            ├── handler/
            │   └── user.go              # HTTPハンドラ（User操作）
            ├── service/
            │   └── user.go              # ビジネスロジック層（optional）
            ├── model/
            │   └── user.go              # ユーザー構造体・DTO
            ├── db/
            │   ├── interface.go         # UserStore interface
            │   ├── postgresql.go        # Postgresql実装
            │   ├── dynamodb.go          # Dynamo実装
            │   └── jsondb.go            # json.db実装（ローカル用）
            ├── logger/
            │   └── logger.go            # zapなどラップ
            ├── config/
            │   └── config.go            # 環境変数、設定読み込み（optional）
            └── tests/
                ├── mock_store.go        # mockUserStore
                └── handler_test.go      # handlerのテスト

✅ さらに明確な分離をしたいとき（将来用）
src/backend/gateway/（API Gateway相当のリバースプロキシ）

src/backend/api-client/（他サービスへのHTTPリクエストまとめ）

src/backend/middleware/（JWT検証などのGin用共通Middleware）

✅ フロントエンドとの接続整理
src/frontend/（Next.js）

BFF不要なら src/frontend/src/app/api.ts などで直接REST呼び出し

APIのベースURLは .env や NEXT_PUBLIC_API_URL で切替

SSRするなら getServerSideProps() → Gin側にリクエスト送る形でもOK
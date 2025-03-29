UbuntuにPostgreSQLの安定版をインストールする手順を説明します：

```
# 1. パッケージ情報の更新
sudo apt update

# 2. PostgreSQLのインストール
sudo apt install -y postgresql postgresql-contrib

# 3. サービスの状態確認

sudo systemctl status postgresql

# 4. 基本的な設定
# PostgreSQLサービスの自動起動設定
sudo systemctl enable postgresql

# デフォルトユーザー(postgres)のパスワード設定
sudo -u postgres psql
# ALTER USER postgres PASSWORD 'postgres';
# \q

# 5. リモートアクセスを許可する場合（必要に応じて）

sudo vim /etc/postgresql/16/main/postgresql.conf
# listen_addresses = '*' のコメントアウトを解除

sudo vim /etc/postgresql/16/main/pg_hba.conf
# 以下の行を追加
# host    all             all             0.0.0.0/0               md5


# 6. サービスの再起動
sudo systemctl restart postgresql
```


基本的な使用方法：
```bash
# PostgreSQLへの接続
psql -U postgres -h localhost

# データベース作成
CREATE DATABASE training;

# データベース一覧表示
\l

# テーブル一覧表示
\dt
```

```
-- テーブル作成
CREATE TABLE micropost (
   id SERIAL PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   image_path TEXT
);

-- 確認用コマンド
\d micropost

-- サンプルデータ挿入
INSERT INTO micropost (title, image_path) VALUES 
('First post', '/images/post1.jpg'),
('Second post', '/images/post2.jpg');

-- データ確認
SELECT * FROM micropost;
```
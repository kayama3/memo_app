# memo_ap
## データベースを定義
`CREATE DATABASE memo_app`
## テーブルを定義
```
CREATE TABLE memo
(id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
 title text,
 text text);
```
## gemをインストール
`$ bundle install`
## アプリを起動
`$ bundle exec ruby main.rb`

# frozen_string_literal:true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

# Description/Explanation of Memo class
class Memo
  CONNECT = PG.connect(dbname: 'memo_app')

  statement_sql = { 'create' => 'INSERT INTO Memo(title, text) VALUES ($1, $2)',
                    'all' => 'SELECT * FROM Memo ORDER BY id',
                    'find' => 'SELECT * FROM Memo WHERE id=$1',
                    'update' => 'UPDATE Memo SET title=$2, text=$3 WHERE id=$1',
                    'delete' => 'DELETE FROM Memo WHERE id=$1' }

  statement_sql.each { |key, val| CONNECT.prepare(key, val) }

  class << self
    def create(title: memo_title, text: memo_text)
      params = [title == '' ? 'NO TITLE' : title, text]
      CONNECT.exec_prepared('create', params)
    end

    def all
      CONNECT.exec_prepared('all').to_a
    end

    def find(id: memo_id)
      CONNECT.exec_prepared('find', [id]).to_a
    end

    def update(id: memo_id, title: memo_title, text: memo_text)
      CONNECT.exec_prepared('update', [id, title, text])
    end

    def delete(id: memo_id)
      CONNECT.exec_prepared('delete', [id])
    end
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# メモ一覧の情報を取得
get '/memos' do
  @hash = Memo.all
  erb :index
end

# メモ作成のためのフォームを表示
get '/memos/new' do
  erb :new
end

# 新しいメモを作成
post '/memos' do
  Memo.create(title: params[:title], text: params[:text])
  redirect '/memos'
end

# 指定のメモの情報を取得
get '/memos/:id' do
  @hash = Memo.find(id: params[:id])
  erb :show
end

# 指定メモを編集するフォームを表示
get '/memos/:id/edit' do
  @hash = Memo.find(id: params[:id])
  erb :edit
end

# 指定のメモを編集
patch '/memos/:id' do
  Memo.update(id: params[:id], title: params[:title], text: params[:text])
  redirect '/memos'
end

# 指定のメモを消去
delete '/memos/:id' do
  Memo.delete(id: params[:id])
  redirect '/memos'
end

not_found do
  '404 Not Found'
end

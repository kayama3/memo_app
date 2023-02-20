# frozen_string_literal:true

require 'json'
require 'sinatra'
require 'sinatra/reloader'

# Description/Explanation of Memo class
class Memo
  @id = 0

  def self.write(file)
    File.open('database.json', 'w') do |f|
      JSON.dump(file, f)
    end
  end

  def self.all
    File.open('database.json') do |f|
      JSON.parse(f.read)
    end
  end

  def self.file(title, text)
    hash = Memo.all
    hash << { "id": @id += 1,
              "title": title == '' ? 'NO TITLE' : title,
              "text": text }
    hash
  end

  def self.edit(id, title, text)
    hash = Memo.all
    hash.each do |v|
      if v['id'].to_s == id
        v['title'] = title
        v['text'] = text
      end
    end
    Memo.write(hash)
  end

  def self.delete(id)
    hash = Memo.all.reject { |i| i['id'].to_s == id }
    Memo.write(hash)
  end
end
Memo.write([])

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
  new = Memo.file(params[:title], params[:text])
  Memo.write(new)
  redirect '/memos'
end

# 指定のメモの情報を取得
get '/memos/:id' do
  @hash = Memo.all
  erb :show
end

# 指定メモを編集するフォームを表示
get '/memos/:id/edit' do
  @hash = Memo.all
  erb :edit
end

# 指定のメモを編集
patch '/memos/:id' do
  Memo.edit(params['id'], params['title'], params['text'])
  redirect '/memos'
end

# 指定のメモを消去
delete '/memos/:id' do
  Memo.delete(params['id'])
  redirect '/memos'
end

not_found do
  '404 Not Found'
end

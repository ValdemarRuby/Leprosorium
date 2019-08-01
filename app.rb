require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
		init_db
end

	# configure вызывается каждый раз при конфигурации приложения:
	# когда изменился код программы и перезагрузилась страница

configure do
		# иницаилизация бд
		init_db
		# создает таблицу если она не существует
		@db.execute 'create table if not exists Posts
			(
				"id" INTEGER PRIMARY KEY AUTOINCREMENT,
				"created_date" DATE,
				"Content" TEXT
				)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School!!!</a>"
end

get '/new' do
	erb :new
end

post '/new' do
	content = params[:content]
	if content.length <= 0
		@error = "Type text"
		return erb :new
	end

	erb "Your typed: #{content}"
end

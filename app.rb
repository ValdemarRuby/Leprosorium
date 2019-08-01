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
		@error = "Type post text"
		return erb :new
	end

	# сохранение данных в бд
	init_db
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	redirect '/posts'
	erb "Your typed: #{content}"
end

get '/posts' do
	# выводим список постов из бд
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

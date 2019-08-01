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
		# создает таблицу для постов если она не существует
		@db.execute 'create table if not exists Posts
			(
				"id" INTEGER PRIMARY KEY AUTOINCREMENT,
				"created_date" DATE,
				"Content" TEXT
				)'

		# создаем таблицу для коментариев для постов
		@db.execute 'create table if not exists Comments
					(
						"id" INTEGER PRIMARY KEY AUTOINCREMENT,
						"created_date" DATE,
						"Content" TEXT,
						"post_id" INTEGER
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

# вывод информации по коментарию
get '/details/:post_id' do
	# получаем переменную из URL-a
	post_id = params[:post_id]

	# получаем список постов
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем коментарии для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ?', [post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, а мы ипринимаем)
post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	# if content.length <= 0
	# 	@error = "Type post text"
	#
	# 	return erb :details
	# end
	@db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]
	erb "You type comment: #{content}"
end

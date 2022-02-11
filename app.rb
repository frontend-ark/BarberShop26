require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'dotenv/load'
require 'sqlite3'

def is_barber_exists? db, name
# если написать в консоли select * from Users where Usernane='Tiny' мы увидим строчку с именем Tiny
  db.execute('select * from Barbers where name=?', [name]).length > 0 
end

def seed_db db, barbers # эта функция будет проходиться
  barbers.each do |barber|# по каждому элементу этого (внизу) массива
    if !is_barber_exists? db, barber # функция (сверху) проверяет существует ли барбер с таким именем и если не существует
      db.execute 'insert into Barbers (name) values (?)', [barber] # то выполнить этот запрос (вставки барбера в нашу бд)
    end
  end
end

def get_db
  db = SQLite3::Database.new 'barber_shop.db'  #создать новое подключение к barber_shop.db
  db.results_as_hash = true
  return db
end

configure do # используется при инициализации приложения(и когда код изменен)
  db = get_db
  db.execute 'CREATE TABLE IF NOT EXISTS "Users" 
   (
     "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "Username" TEXT,
     "Phone" TEXT,
     "DateStamp" TEXT,
     "Barber" TEXT,
     "Color" TEXT
   )'

  db.execute 'CREATE TABLE IF NOT EXISTS "Barbers" 
   (
     "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "name" TEXT
   )'

   seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut'] # при обновлении страницы произойдет кофинурация и вызовется эта функция с массивом который мы задали

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

get '/showusers' do
  db = get_db
  @results = db.execute 'select * from Users order by id desc'
  erb :showusers
end

post '/visit' do

	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

hh_visit = {
	:username => 'Введите имя', # :ключ => 'значение'
	:phone => 'Введите телефон', 
	:datetime => 'Введите дату и время'
}

@error = hh_visit.select {|key,_| params[key] == ''}.values.join(', ')

if @error != ''
	return erb :visit
end # единственный момент что такую штуку придется писать на каждый url

db = get_db
db.execute 'insert into 
Users (Username, Phone, DateStamp, Barber, Color) 
values (?,?,?,?,?)', [@username, @phone, @datetime, @barber, @color]
#сохранение данных в базу

erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}"

end

post '/contacts' do
  @email_name = params[:email_name]
  @story = params[:story]
  @email = params[:email]


  hh_contacts = {
 		:email_name => "You didn't enter your name",
  	:story => "You wrote nothing",
  	:email => "You didn't enter your email address"
  }

  @error = hh_contacts.select {|key,_| params[key] == ''}.values.join(', ')

	if @error != ''
		return erb :contacts
	end

	@error = nil
  @title = 'Thank you!'
  @message = "We would be glad to read your message"

  # f = File.open('./public/message.txt', 'a') # это запись в файл
  # f.write "\nMessage: #{@story}, e-mail: #{@email}"
  # f.close

  vars = {
		to: ENV['USER_IMAIL_ADDRESS'],
	  subject: @email_name + " has contacted you",
	  body: @story,
	  via: :smtp,
	  via_options: { 
	    address: 'smtp.gmail.com', 
	    port: '587', 
	    enable_starttls_auto: true, 
	    user_name: ENV['USER_IMAIL_ADDRESS'], 
	    password: ENV['SMTP_PASSWORD'], 
	    authentication: :login, # :plain, :login, :cram_md5, no auth by default
	    domain:'mail.google.com'
	  }
  }

	Pony.mail(vars)

  erb :message
end

post '/admin' do
  @login = params[:login]
  @password = params[:password]

  if @login == 'admin' && @password == '12345'
    @message = 'You win!'
    @logfile = File.open('./public/users.txt', 'r')
    erb :admin
  else
    @message = 'Go away, muggle!'
  end
end





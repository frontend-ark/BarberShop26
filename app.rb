require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'dotenv/load'
require 'sqlite3'

configure do
  @db = SQLite3::Database.new 'barber_shop.db' #создать новое подключение к barber_shop.db
  @db.execute 'CREATE TABLE IF NOT EXISTS
   "Users" 
   (
     "Id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "Name" TEXT,
     "Phone" TEXT,
     "DateStamp" TEXT,
     "Barber" TEXT,
     "Color" TEXT
   )'
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
end

# единственный момент что такую штуку придется писать на каждый url

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

  # f = File.open('./public/message.txt', 'a') # запись в файл
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



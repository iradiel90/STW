require 'sinatra'
set server: 'thin', connections: {}

get '/' do
  path = File.dirname(__FILE__)
  halt erb(:login) if params[:user].nil?
  erb :chat, locals: { user: params[:user], path: path }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections[params[:user]] = out
    out.callback do
	 settings.connections.delete params[:user] 
    end
  end
end

post '/' do
  info = []
  info[0] = params[:msg]
  info[1] = settings.connections.keys
  pmsg = /(.+):.*\/(.+):(.*)/
  msg = pmsg.match(params[:msg])
  connection = settings.connections[msg[2]] unless msg.nil?
  if connection.nil?
    info[2] = "g"
    settings.connections.each_pair { |user, out| out << "data: #{info}\n\n" }
    204 # response without entity body
  else
    info[0] = "#{msg[1]}: #{msg[3]}\n\n"
    info[2] = "p"
    connection << "data: #{info}\n\n"
    info[0] = ">#{msg[2]}: #{msg[3]}\n\n"
    settings.connections[msg[1]] << "data: #{info}\n\n"
    204 # response without entity body
  end
end

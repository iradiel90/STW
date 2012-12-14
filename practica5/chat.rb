require 'sinatra'
set server: 'thin', connections: {}

get '/' do
  halt erb(:login) if params[:user].nil?
  erb :chat, locals: { user: params[:user] }
end

get '/stream/:user', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections[params[:user]] = out
    out.callback { settings.connections.delete params[:user] }
  end
end

post '/' do
  pmsg = /(.+):.*\/(.+):(.*)/
  msg = pmsg.match(params[:msg])
  connection = settings.connections[msg[2]] unless msg.nil?
  if connection.nil?
    settings.connections.each_pair { |user, out| out << "data: #{params[:msg]}\n\n" }
    204 # response without entity body
  else
    connection << "data: MP de #{msg[1]}: #{msg[3]}\n\n"
    settings.connections[msg[1]] << "data: MP para #{msg[2]}: #{msg[3]}\n\n"
    204 # response without entity body
  end
end
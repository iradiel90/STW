# coding: utf-8
require 'sinatra'
set server: 'thin', connections: []
#set connections: []

get '/' do
	halt erb(:login) unless params[:user]
	erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream', provides: 'text/event-stream' do
	stream :keep_open do |out|
		settings.connections << out
		out.callback { settings.connections.delete(out) }
	end
end

# get '/', :provides => ['rss', 'atom', 'xml'] do
# 	builder :feed
# end

post '/' do
	settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
	204 # response without entity body
end

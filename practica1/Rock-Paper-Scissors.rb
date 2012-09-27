require 'sinatra'
require 'erb'

# before we process a route we'll set the response as plain text
# and set up an array of viable moves that a player (and the
# computer) can perform
before do
  @defeat = { :rock => :scissors, :paper => :rock, :scissors => :paper}
  @throws = @defeat.keys
end

get '/' do
	erb :form
end

get '/throw/:type' do
  # the params hash stores querystring and form data
  @player_throw = params[:type].to_sym

  halt(403, "You must throw one of the following: '#{@throws.join(', ')}'") unless @throws.include? @player_throw

  @computer_throw = @throws.choice

  if @player_throw == @computer_throw 
    @answer = "There is a tie"
	 @img= "tie"
  elsif @player_throw == @defeat[@computer_throw]
    @answer = "Sorry. #{@computer_throw} beats #{@player_throw}"
	 @img= "sorry"
  else
    @answer = "Well done. #{@player_throw} beats #{@computer_throw}"
	 @img= "congrats"
  end
  erb :result
end

post '/throw' do
	if params[:eleccion]
		@params = params[:eleccion].to_sym
	else
		@params = @throws.choice
	end
	if @throws.include? @params
		redirect "/throw/#{@params}"
	else
		redirect "/"
	end
end


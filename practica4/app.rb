require 'sinatra'
require 'sinatra/activerecord'
require 'haml'

set :database, 'sqlite3:///shortened_urls.db'
#set :address, 'localhost:4567'
set :address, 'exthost.etsii.ull.es:4567'

class ShortenedUrl < ActiveRecord::Base
	# Validates whether the value of the specified attributes are unique across the system.
	validates_uniqueness_of :url
	# Validates that the specified attributes are not blank
	validates_presence_of :url
	#validates_format_of :url, :with => /.*/
	validates_format_of :url, 
		:with => %r{^(https?|ftp)://.+}i, 
		:allow_blank => true, 
		:message => "The URL must start with http://, https://, or ftp:// ."
end

get '/' do
	haml :index
end

post '/' do
	if params[:custom].present?
		@short_url = ShortenedUrl.find_or_create_by_custom_url_and_url(params[:custom], params[:url])
	else
		@short_url = ShortenedUrl.find_or_create_by_url(params[:url])
	end
	if @short_url.valid?
		haml :success, :locals => { :address => settings.address }
	else
		haml :index
	end
end

get '/show' do
	@urls = ShortenedUrl.find(:all)
	haml :show
end

post '/search' do
	@searched_url = ShortenedUrl.find_by_custom_url(params[:search])
	if !@searched_url.present?
		@searched_url = ShortenedUrl.find_by_id(params[:search].to_i(36))
	end
 	@searched_id = ShortenedUrl.find_by_url(params[:search])
 	haml :search
end

get '/:shortened' do
	short_url = ShortenedUrl.find_by_custom_url(params[:shortened])
	if !short_url.present?
		short_url = ShortenedUrl.find_by_id(params[:shortened].to_i(36))
	end
	redirect short_url.url
end
# encoding utf-8

require 'sinatra'
require 'sinatra/flash'
require 'sass'
require 'haml'
require_relative 'lib/datasift/lib/datasift'

# Require all in lib directory
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

class App < Sinatra::Application

  # Load config.yml into settings.config variable
  set :config, YAML.load_file("#{root}/config/config.yml")[settings.environment.to_s]

  set :environment, ENV["RACK_ENV"] || "development"
  set :haml, { :format => :html5 }

  ######################################################################
  # Configurations for different environments
  ######################################################################

  configure :staging do
    enable :logging
  end

  configure :development do
    enable :logging
  end

  ######################################################################

end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  # More methods in /helpers/*
end

require_relative 'models/init'
require_relative 'helpers/init'

########################################################################
# Routes/Controllers
########################################################################

def protect_with_http_auth!
  protected!(settings.config["http_auth_username"], settings.config["http_auth_password"])
end

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

get '/css/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :'sass/style'
end

get '/' do
  @page_name = "home"
  haml :index, :layout => :'layouts/application'
end

def load_definition(name)
  filepath = "#{File.dirname(__FILE__)}/config/definitions/#{name}.datasift"
  File.open(filepath, "rb").read
end

get '/stream' do
  datasift_user = DataSift::User.new(settings.config['datasift_username'], settings.config['datasift_api_key'])
  definition_name = "olympics"

  definition = datasift_user.createDefinition(load_definition(definition_name))
  consumer = definition.getConsumer(DataSift::StreamConsumer::TYPE_HTTP)

  # TODO: Figure out how to get out of the loop
  # consumer.consume(true) do |interaction|
  #   puts interaction if interaction
  #   return
  # end

end

# -----------------------------------------------------------------------
# Error handling
# -----------------------------------------------------------------------

not_found do
  logger.info "not_found: #{request.request_method} #{request.url}"
end

# All errors
error do
  @page_name = "error"
  @is_error = true
  haml :error, :layout => :'layouts/application'
end

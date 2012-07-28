# encoding: utf-8
require 'sinatra/base'

module Sinatra
  module HttpAuthentication
    def protected!(username, password)
      unless authorized?(username, password)
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?(username, password)
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
    end
  end

  helpers HttpAuthentication
end
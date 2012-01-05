# -*- mode:ruby; coding:utf-8 -*-
require 'rubygems'
require 'json'
require 'atig/http'

module Atig
  class Bitly
    class << self
      def no_login(logger)
        self.new logger, nil, nil
      end

      def login(logger, login, key)
        self.new logger, login, key
      end
    end

    def initialize(logger, login, key)
      @log   = logger
      @login = login
      @key   = key
      @http  = Http.new logger
    end

    def shorten(url)
      return url if url =~ /bit\.ly/
      bitly = URI("http://api.bit.ly/v3/shorten")
      if @login and @key
        bitly.path  = "/shorten"
        bitly.query = {
          :format => "json", :longUrl => url, :login => @login, :apiKey => @key,
        }.to_query_str(";")
        req = @http.req(:get, bitly, {})
        res = @http.http(bitly, 5, 10).request(req)

        res = JSON.parse(res.body)

        if res['statusCode'] == "ERROR" then
          @log.error res['errorMessage']
          url
        else
          res["results"][url]['shortUrl']
        end
      else
        url
      end
    rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
      @log.error e
      url
    end
  end
end

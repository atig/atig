#! /opt/local/bin/ruby -w
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
      bitly = URI("http://api.bit.ly/shorten")
      if @login and @key
        bitly.path  = "/shorten"
        bitly.query = {
          :version => "2.0.1", :format => "json", :longUrl => url,
        }.to_query_str(";")
        req = @http.req(:get, bitly, {}, [@login, @key])
        res = @http.http(bitly, 5, 10).request(req)
        res = JSON.parse(res.body)
        res["results"][url]['shortUrl']
      else
        bitly.path = "/api"
        bitly.query = { :url => url }.to_query_str
        req = @http.req(:get, bitly)
        res = @http.http(bitly, 5, 5).request(req)
        res.body
      end
    rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
      @log.error e
      text
    end
  end
end

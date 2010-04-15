#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "json"
require 'atig/twitter_struct'
require 'atig/basic_twitter'
require 'atig/http'

module Atig
  # from tig.rb
  class Twitter < BasicTwitter
    def initialize(context, oauth)
      super context, :api_base
      @oauth = oauth
      @http  = Atig::Http.new @log
    end

    # authenticate = trueでないとSSL verified errorがでることがある
    def page(path, name, authenticate = true, &block)
      limit = 0.98 * @remain # 98% of IP based rate limit
      r     = []
      cursor = -1
      1.upto(limit) do |num|
        # next_cursor にアクセスするとNot found が返ってくることがあるので，その時はbreak
        ret = api(path, { :cursor => cursor }, { :authenticate => authenticate }) rescue break
        arr = ret[name.to_s]
        r.concat arr
        cursor = ret[:next_cursor]
        break if cursor.zero?
      end
      r
    end

    def self.http_methods(*methods)
      methods.each do |m|
        self.module_eval <<END
          def #{m}(path, query = {}, opts = {})
            opts.update( :method => :#{m})
            api path, query, opts
          end
END
      end
    end
    http_methods :get, :post, :put, :delete

    protected
    def request(uri, opts)
      authenticate = opts.fetch(:authenticate, true)
      method       = opts.fetch(:method, :get)

      header      = {}
      req         = @http.req method, uri, header
      @log.debug [req.method, uri.to_s]
      if authenticate
        oauth 30, req
      else
        @http.http(uri, 30, 30).request req
      end
    end

    def api_base(secure = true)
      URI(@opts.api_base)
    end

    def oauth(time, req)
      timeout(time) do
        headers = {}
        req.each{|k,v| headers[k] = v }

        case req
        when Net::HTTP::Get
          @oauth.get req.path,headers
        when Net::HTTP::Head
          @oauth.head req.path,headers
        when Net::HTTP::Post
          @oauth.post req.path,req.body,headers
        when Net::HTTP::Put
          @oauth.put req.path,req.body,headers
        when Net::HTTP::Delete
          @oauth.delete req.path,headers
        end
      end
    end
  end
end

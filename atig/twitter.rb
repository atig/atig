#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "json"
require 'atig/twitter_struct'
require 'atig/http'

module Atig
  # from tig.rb
  class Twitter
    attr_reader :limit, :remain

    class APIFailed < StandardError; end

    def initialize(context, oauth)
      @log   = context.log
      @opts  = context.opts
      @oauth = oauth
      @http  = Atig::Http.new @log

      @limit = @remain = 150
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


    def api(path, query = {}, opts = {})
      path.sub!(%r{\A/+}, "")

      authenticate = opts.fetch(:authenticate, true)
      method = opts.fetch(:method, :get)

      uri = api_base(authenticate)
      uri.path += path
      uri.path += ".json" if path != "users/username_available"
      uri.query = query.to_query_str unless query.empty?

      header      = {}
      req         = @http.req method, uri, header

      @log.debug [req.method, uri.to_s]
      begin
        if authenticate
          ret = oauth 30, req
        else
          ret = http(uri, 30, 30).request req
        end
      rescue OpenSSL::SSL::SSLError => e
        @log.error e.inspect
        raise e.inspect
      end

      if ret["X-RateLimit-Limit"] then
        hourly_limit = ret["X-RateLimit-Limit"].to_i
        unless hourly_limit.zero?
          if @limit != hourly_limit
            msg = "The rate limit per hour was changed: #{@limit} to #{hourly_limit}"
            @log.info msg
            @limit = hourly_limit
          end
        end
      end

      if ret["X-RateLimit-Remaining"] then
        @remain = ret["X-RateLimit-Remaining"].to_i
        @log.debug "IP based limit: #{@remain}"
      end

      case ret
      when Net::HTTPOK # 200
        # Avoid Twitter's invalid JSON
        json = ret.body.strip.sub(/\A(?:false|true)\z/, "[\\&]")

        res = JSON.parse(json)
        if res.is_a?(Hash) && res["error"] # and not res["response"]
          if @error != res["error"]
            @error = res["error"]
            log @error
          end
          raise APIFailed, res["error"]
        end

        TwitterStruct.make(res)
      when Net::HTTPNoContent,  # 204
        Net::HTTPNotModified # 304
        []
      when Net::HTTPBadRequest # 400: exceeded the rate limitation
        if ret.key?("X-RateLimit-Reset")
          @log.info "waiting for rate limit reset"
          s = ret["X-RateLimit-Reset"].to_i - Time.now.to_i
          if s > 0
            sleep [s, 60 * 10].min # 10 分に一回はとってくるように
          end
        end
        raise APIFailed, "#{ret.code}: #{ret.message}"
      when Net::HTTPUnauthorized # 401
        raise APIFailed, "#{ret.code}: #{ret.message}"
      else
        raise APIFailed, "Server Returned #{ret.code} #{ret.message}"
      end
    rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
      raise APIFailed, e.inspect
    end

    private
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

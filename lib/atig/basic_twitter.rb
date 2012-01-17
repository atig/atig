#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "json"
require 'atig/twitter_struct'
require 'atig/http'

module Atig
  # from tig.rb
  class BasicTwitter
    attr_reader :limit, :remain, :reset

    class APIFailed < StandardError; end

    def initialize(context, api_base)
      @log   = context.log
      @opts  = context.opts
      @api_base = api_base
      @http  = Atig::Http.new @log

      @limit = @remain = 150
    end

    def api(path, query = {}, opts = {})
      path.sub!(%r{\A/+}, "")

      uri = api_base
      uri.path += path
      uri.path += ".json" if path != "users/username_available"
      uri.query = query.to_query_str unless query.empty?

      header      = {}

      begin
        ret = request(uri, opts)
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

      if ret["X-RateLimit-Reset"] then
        @reset = ret["X-RateLimit-Reset"].to_i
        @log.debug "RateLimit Reset: #{@reset}"
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
            sleep (s > 60 * 10) ? 60 * 10 : s # 10 分に一回はとってくるように
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

    private
    def api_base
      URI(@opts.send @api_base)
    end
  end
end

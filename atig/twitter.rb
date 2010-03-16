#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "json"
require 'atig/twitter_struct'
require 'atig/http'

module Atig
  # from tig.rb
  class Twitter
    attr_reader :auth_limit, :ip_limit

    class APIFailed < StandardError; end

    def initialize(logger, oauth)
      @log = logger
      @oauth = oauth
      @http = Atig::Http.new @log

      @ip_limit   = 52
      @auth_limit = 150
    end

    def page(path, name, authenticate = false, &block)
      limit = 0.98 * @ip_limit # 98% of IP based rate limit
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
          ret = oauth req
        else
          ret = http(uri, 30, 30).request req
        end
      rescue OpenSSL::SSL::SSLError => e
        @log.error e.inspect
        raise e.inspect
      end

      case
      when authenticate
        hourly_limit = ret["X-RateLimit-Limit"].to_i
        unless hourly_limit.zero?
          if @auth_limit != hourly_limit
            msg = "The rate limit per hour was changed: #{@auth_limit} to #{hourly_limit}"
            @log.info msg
            @auth_limit = hourly_limit
          end
        end
      when ret["X-RateLimit-Remaining"]
        @ip_limit = ret["X-RateLimit-Remaining"].to_i
        @log.debug "IP based limit: #{@ip_limit}"
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

    private
    def server_name
      "twittergw"
    end

    def server_version
      @server_version ||= instance_eval {
        head = `git rev-parse HEAD 2>/dev/null`.chomp
        head.empty?? "unknown" : head
      }
    end


    def http(uri, open_timeout = nil, read_timeout = 60)
      http = case
             when @httpproxy
               Net::HTTP.new(uri.host, uri.port, @httpproxy.address, @httpproxy.port,
                             @httpproxy.user, @httpproxy.password)
             when ENV["HTTP_PROXY"], ENV["http_proxy"]
               proxy = URI(ENV["HTTP_PROXY"] || ENV["http_proxy"])
               Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port,
                             proxy.user, proxy.password)
             else
               Net::HTTP.new(uri.host, uri.port)
             end
      http.open_timeout = open_timeout if open_timeout # nil by default
      http.read_timeout = read_timeout if read_timeout # 60 by default
      if uri.is_a? URI::HTTPS
        http.use_ssl     = true
        http.cert_store = @cert_store
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http
    rescue => e
      @log.error e
    end

    def http_req(method, uri, header = {}, credentials = nil)
      accepts = ["*/*;q=0.1"]
      types   = { "json" => "application/json", "txt" => "text/plain" }
      ext     = uri.path[/[^.]+\z/]
      accepts.unshift types[ext] if types.key?(ext)
      user_agent = "#{self.class}/#{server_version} (#{File.basename(__FILE__)}; net-irc) Ruby/#{RUBY_VERSION} (#{RUBY_PLATFORM})"

      header["User-Agent"]      ||= user_agent
      header["Accept"]          ||= accepts.join(",")
      header["Accept-Charset"]  ||= "UTF-8,*;q=0.0" if ext != "json"

      req = case method.to_s.downcase.to_sym
            when :get
              Net::HTTP::Get.new    uri.request_uri, header
            when :head
              Net::HTTP::Head.new   uri.request_uri, header
            when :post
              Net::HTTP::Post.new   uri.path,        header
            when :put
              Net::HTTP::Put.new    uri.path,        header
            when :delete
              Net::HTTP::Delete.new uri.request_uri, header
            else # raise ""
            end
      if req.request_body_permitted?
        req["Content-Type"] ||= "application/x-www-form-urlencoded"
        req.body = uri.query
      end
      req.basic_auth(*credentials) if credentials
      req
    rescue => e
      @log.error e
    end

    def api_base(secure = true)
      URI("http#{"s" if secure}://twitter.com/")
    end

    def api_source
      "#{@opts.api_source || "tigrb"}"
    end

    def oauth(req)
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


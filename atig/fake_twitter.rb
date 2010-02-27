#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "net/https"
require "json"
require 'atig/twitter_struct'
require 'atig/http'

module Atig
  # from tig.rb
  class FakeTwitter
    def initialize(logger,*_)
      @log = logger
      @http = Atig::Http.new logger
    end

    def self.http_methods(*methods)
      methods.each do |m|
        self.module_eval <<END
          def #{m}(path, query = {}, opts = {})
            api path, query, opts
          end
END
      end
    end
    http_methods :get, :post, :put, :delete


    def api(path, query = {}, opts = {})
      path.sub!(%r{\A/+}, "")

      method = :get
      uri = URI("http://localhost:8001/")
      uri.path += path
      uri.path += ".json" if path != "users/username_available"

      req  = @http.req method, uri, {},nil
      @log.debug [req.method, uri.to_s]
      begin
        ret = @http.http(uri, 30, 30).request req
      rescue OpenSSL::SSL::SSLError => e
        @log.error e.inspect
        raise e.inspect
      end

      json = ret.body.strip.sub(/\A(?:false|true)\z/, "[\\&]")

      res = JSON.parse(json)
      TwitterStruct.make(res)
    end
  end
end


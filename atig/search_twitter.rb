# -*- mode:ruby; coding:utf-8 -*-
require 'atig/basic_twitter'
require 'atig/http'

module Atig
  # from tig.rb
  class SearchTwitter < BasicTwitter
    def initialize(context)
      super context, :search_api_base
      @http  = Atig::Http.new @log
    end

    protected
    def request(uri, opts)
      header      = {}
      req         = @http.req :get, uri, header
      @log.debug [req.method, uri.to_s]
      @http.http(uri, 30, 30).request req
    end
  end
end

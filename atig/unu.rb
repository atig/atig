#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
module Atig
  class Unu
    def initialize(logger)
      @log = logger
      @http = Atig::Http.new logger
    end

    def shorten(url)
      unu_url = "http://u.nu/"
      unu     = URI("#{unu_url}unu-api-simple")
      url = URI.rstrip url
      unu.query = { :url => url }.to_query_str
      res = @http.http(unu, 5, 5).request(@http.req(:get, unu)).body

      if res[0, 12] == unu_url
        res
      else
        @log.error res
        url
      end
    rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
      @log.error e
      url
    end
  end
end

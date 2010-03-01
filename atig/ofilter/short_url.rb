#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/unu'
require 'atig/bitly'

module Atig
  module OFilter
    class ShortUrl
      MIN_LEN = 20

      def initialize(logger, opts)
        @log = logger
        @http = Atig::Http.new logger

        @shorten = case
                   when opts.bitlify.to_s.include?(":")
                     login, key, len = opts.bitlify.to_s.split(":", 3)
                     @len = (len || MIN_LEN).to_i
                     Bitly.login logger, login, key
                   when opts.bitlify
                     @len = (opts.bitlify.to_s || MIN_LEN).to_i
                     Bitly.no_login logger
                   when opts.unuify
                     @len = (opts.unuify.to_s || MIN_LEN).to_i
                     Unu.new logger
                   end
      end

      def call(status)
        mesg = status[:status]
        status.merge(:status => short_urls(mesg))
      end

      def short_urls(mesg)
        mesg unless @shorten
        mesg.gsub(URI.regexp(%w[http https])) do|url|
          if URI.rstrip(url).size < @len then
            url
          else
            @shorten.shorten url
          end
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module OFilter
    class ShortUrl
      def initialize(logger, opts)
        @log = logger
        @opts = opts
        @http = Atig::Http.new logger
      end

      def call(status)
        mesg = status[:status]
        status.merge(:status =>
                     @opts.unuify ? unuify(mesg) : bitlify(mesg))
      end

      def bitlify(text)
        login, key, len = @opts.bitlify.to_s.split(":", 3) if @opts.bitlify
        len      = (len || 20).to_i
        longurls = URI.extract(text, %w[http https]).uniq.map do |url|
          URI.rstrip url
        end.reject do |url|
          url.size < len
        end
        return text if longurls.empty?

        bitly = URI("http://api.bit.ly/shorten")
        if login and key
          bitly.path  = "/shorten"
          bitly.query = {
            :version => "2.0.1", :format => "json", :longUrl => longurls,
          }.to_query_str(";")
          @log.debug bitly
          req = @http.req(:get, bitly, {}, [login, key])
          res = @http.http(bitly, 5, 10).request(req)
          res = JSON.parse(res.body)
          res = res["results"]

          longurls.each do |longurl|
            text.gsub!(longurl) do
              res[$&] && res[$&]["shortUrl"] || $&
            end
          end
        else
          bitly.path = "/api"
          longurls.each do |longurl|
            bitly.query = { :url => longurl }.to_query_str
            @log.debug bitly
            req = @http.req(:get, bitly)
            res = @http.http(bitly, 5, 5).request(req)
            text.gsub!(longurl, res.body)
          end
        end

        text
      rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
        @log.error e
        text
      end

      def unuify(text)
        unu_url = "http://u.nu/"
        unu     = URI("#{unu_url}unu-api-simple")
        size    = unu_url.size

        text.gsub(URI.regexp(%w[http https])) do |url|
          url = URI.rstrip url
          if url.size < size + 5 or url[0, size] == unu_url
            return url
          end

          unu.query = { :url => url }.to_query_str
          @log.debug unu

          res = @http.http(unu, 5, 5).request(@http.req(:get, unu)).body

          if res[0, 12] == unu_url
            res
          else
            raise res.split("|")
          end
        end
      rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
        @log.error e
        text
      end
    end
  end
end

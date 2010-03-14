#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/http'
require 'atig/url_escape'

begin
  require "punycode"
rescue LoadError
end

module Atig
  module OFilter
    class EscapeUrl
      include Util
      def initialize(context)
        @log  = context.log
        @http = Atig::Http.new @log
      end

      def call(status)
        status.merge(:status => escape_http_urls(status[:status]))
      end

      def exist_uri?(uri, limit = 1)
        ret = nil
        #raise "Not supported." unless uri.is_a?(URI::HTTP)
        return ret if limit.zero? or uri.nil? or not uri.is_a?(URI::HTTP)
        @log.debug uri.inspect

        req = @http.req :head, uri
        @http.http(uri, 3, 2).request(req) do |res|
          ret = case res
                when Net::HTTPSuccess
                true
                when Net::HTTPRedirection
                uri = resolve_http_redirect(uri)
                  exist_uri?(uri, limit - 1)
                when Net::HTTPClientError
                  false
                else
                  nil
                end
        end
        ret
      rescue => e
        @log.error e.inspect
        ret
      end

      def escape_http_urls(text)
        original_text = text.encoding!("UTF-8").dup

        if defined? ::Punycode
          # TODO: Nameprep
          text.gsub!(%r{(https?://)([^\x00-\x2C\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]+)}) do
            domain = $2
            # Dots:
            #   * U+002E (full stop)           * U+3002 (ideographic full stop)
            #   * U+FF0E (fullwidth full stop) * U+FF61 (halfwidth ideographic full stop)
            # => /[.\u3002\uFF0E\uFF61] # Ruby 1.9 /x
            $1 + domain.split(/\.|\343\200\202|\357\274\216|\357\275\241/).map do |label|
              break [domain] if /\A-|[\x00-\x2C\x2E\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]|-\z/ === label
              next label unless /[^-A-Za-z0-9]/ === label
              punycode = Punycode.encode(label)
              break [domain] if punycode.size > 59
              "xn--#{punycode}"
            end.join(".")
          end
          if text != original_text
            log :info, "Punycode encoded: #{text}"
            original_text = text.dup
          end
        end

        urls = []
        text.split(/[\s<>]+/).each do |str|
          next if /%[0-9A-Fa-f]{2}/ === str
          # URI::UNSAFE + "#"
          escaped_str = URI.escape(str, %r{[^-_.!~*'()a-zA-Z0-9;/?:@&=+$,\[\]#]}) #'
          URI.extract(escaped_str, %w[http https]).each do |url|
            uri = URI(URI.rstrip(url))
            if not urls.include?(uri.to_s) and self.exist_uri?(uri)
              urls << uri.to_s
            end
          end if escaped_str != str
        end
        urls.each do |url|
          unescaped_url = URI.unescape(url).encoding!("UTF-8")
          text.gsub!(unescaped_url, url)
        end
        log :info, "Percent encoded: #{text}" if text != original_text

        text.encoding!("UTF-8")
      rescue => e
        log :error, e
        text
      end
    end
  end
end


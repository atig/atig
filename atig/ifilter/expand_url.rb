#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/http'

module Atig
  module IFilter
    class ExpandUrl
      include Util
      def initialize(context)
        @log  = context.log
        @opts = context.opts
        @http = Atig::Http.new @log
      end

      def call(status)
        target = if @opts.untiny_whole_urls then
                   URI.regexp(%w[http https])
                 else
                   %r{
			http:// (?:
				(?: bit\.ly | (?: tin | rub) yurl\.com | j\.mp
				  | is\.gd | cli\.gs | tr\.im | u\.nu | airme\.us
				  | ff\.im | twurl.nl | bkite\.com | tumblr\.com
				  | pic\.gd | sn\.im | digg\.com )
				/ [0-9a-z=-]+ |
				blip\.fm/~ (?> [0-9a-z]+) (?! /) |
				flic\.kr/[a-z0-9/]+
			)
		   }ix
                 end

        status.merge :text => status.text.gsub(target) {|url|
          resolve_http_redirect(URI(url)).to_s || url
        }
      end

      def resolve_http_redirect(uri, limit = 3)
        return uri if limit.zero? or uri.nil?
        log :debug, uri.inspect
        req = @http.req :head, uri
        @http.http(uri, 3, 2).request(req) do |res|
          break if not res.is_a?(Net::HTTPRedirection) or
            not res.key?("Location")
          begin
            location = URI(res["Location"])
          rescue URI::InvalidURIError
          end
          unless location.is_a? URI::HTTP
            begin
              location = URI.join(uri.to_s, res["Location"])
            rescue URI::InvalidURIError, URI::BadURIError
              # FIXME
            end
          end
          uri = resolve_http_redirect(location, limit - 1)
        end

        uri
      rescue Errno::ETIMEDOUT, IOError, Timeout::Error, Errno::ECONNRESET => e
        log :error, e.inspect
        uri
      end
    end
  end
end

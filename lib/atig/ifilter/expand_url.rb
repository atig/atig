# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/http'
require 'atig/sized_hash'

module Atig
  module IFilter
    class ExpandUrl
      include Util
      def initialize(context)
        @log  = context.log
        @opts = context.opts
        @http = Atig::Http.new @log
        @cache = Atig::SizedHash.new 100
      end

      def call(status)
        target = short_url_regexp
        entities = (entities = status.entities).nil? ? [] : entities.urls
        status.merge :text => status.text.gsub(target) {|url|
          unless entities.nil? or entities.empty?
            @cache[url] ||= search_url_from_entities(url, entities)
            url = @cache[url] if @cache[url] =~ target
          end
          @cache[url] ||= resolve_http_redirect(URI(url)).to_s || url
        }
      end

      private

      def short_url_regexp
        return URI.regexp(%w[http https]) if @opts.untiny_whole_urls
        %r{
          https?:// (?:
                    (?: t (?: mblr )? \.co
                      | (?: bitly | bkite | digg | tumblr | (?: tin | rub ) yurl ) \.com
                      | (?: is | pic ) \.gd
                      | goo\.gl
                      | cli\.gs
                      | (?: ff | sn | tr ) \.im
                      | bit\.ly
                      | j\.mp
                      | nico\.ms
                      | airme\.us
                      | twurl\.nl
                      | htn\.to)
                    / [0-9a-z=-]+ |
                    blip\.fm/~ (?> [0-9a-z]+) (?! /) |
                    flic\.kr/[a-z0-9/]+
          )
        }ix
      end

      def search_url_from_entities(url, entities)
        expanded_url = nil
        entities.reject! do |entity|
          entity.url == url &&
            (expanded_url = entity.expanded_url)
        end
        expanded_url
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

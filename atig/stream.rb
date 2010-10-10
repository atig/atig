#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'json'
require 'uri'
require 'logger'
require 'atig/twitter_struct'
require 'atig/util'
require 'atig/url_escape'

module Atig
  class Stream
    include Util

    class APIFailed < StandardError; end
    def initialize(context, oauth)
      @log   = context.log
      @opts  = context.opts
      @oauth = oauth
    end

    def watch(path, query={}, &f)
      path.sub!(%r{\A/+}, "")

      uri = api_base
      uri.path += path
      uri.path += ".json"
      uri.query = query.to_query_str unless query.empty?

      @log.debug [uri.to_s]

      begin
        @oauth.get(uri.path) do|response|
          unless response.code == '200' then
            raise APIFailed,"#{response.code} #{response.message}"
          end
          begin
            buffer = ''
            response.read_body do |chunk|
              next if chunk.chomp.empty?
              buffer << chunk.to_s
              if buffer =~ /\A(.*)\n/ then
                text = $1
                unless text.strip.empty?
                  f.call TwitterStruct.make(JSON.parse(text))
                end
                buffer = ''
              end
            end
          rescue => e
            raise APIFailed,e.to_s
          end
        end
      rescue => e
        raise APIFailed,e.to_s
      end
    end

    def api_base
      URI(@opts.stream_api_base)
    end
  end
end

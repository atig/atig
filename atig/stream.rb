#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'json'
require 'uri'
require 'logger'
require 'atig/twitter_struct'
require 'atig/url_escape'

module Atig
  class Stream
    class APIFailed < StandardError; end
    def initialize(context, user, password)
      @log      = context.log
      @opts     = context.opts
      @user     = user
      @password = password
    end

    def watch(path, query={}, &f)
      path.sub!(%r{\A/+}, "")

      uri = api_base
      uri.path += path
      uri.path += ".json"
      uri.query = query.to_query_str unless query.empty?

      @log.debug [uri.to_s]
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new uri.request_uri
        request.basic_auth @user, @password
        http.request(request) do |response|
          response.read_body do |chunk|
            next if chunk.strip.empty?
            begin
              f.call TwitterStruct.make(JSON.parse(chunk))
            rescue => e
              @log.error e.inspect
            end
          end
        end
      end
    end

    def api_base
      URI(@opts.stream_api_base)
    end
  end
end

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

      timeout = @opts.stream_timeout || 60*60
      if timeout != 0 then
        loop{
          begin
            streaming(uri, timeout, &f)
          rescue TimeoutError
          end
        }
      else
        streaming(uri,&f)
      end
    end

    def read(http, request, &f)
      buffer = ''
      http.request(request) do |response|
        unless response.code == '200' then
          raise APIFailed,"#{response.code} #{response.message}"
        end

        response.read_body do |chunk|
          next if chunk.strip.empty?
          buffer << chunk
          begin
            while buffer =~ /\A.*?\r\n/ do
              json    = $&
              buffer  = $'
              f.call TwitterStruct.make(JSON.parse(json))
            end
          rescue => e
            @log.error e.inspect
          end
        end
      end
    end

    def streaming(uri, read_time =nil,&f)
      @log.debug [uri.to_s]
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new uri.request_uri
        request.basic_auth @user, @password

        if read_time then
          timeout( read_time ){
            read(http, request,&f)
          }
        else
          read(http, request,&f)
        end
      end
    end

    def api_base
      URI(@opts.stream_api_base)
    end
  end
end

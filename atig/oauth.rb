#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'oauth'
require 'oauth-patch'

module Atig
  class OAuth
    CONSUMER_KEY = 'TO9wbD379qmFSJp6pFs5w'
    CONSUMER_SECRET = 'Gap8ishP3J3JrjH4JEspcii4poiZgMowHRazWGM1cYg'

    @@profiles = {}
    class << self
      def dump
        @@profiles
      end

      def load(profiles)
        @@profiles = profiles
      end
    end

    attr_reader :access, :stream_access
    def initialize(context, nick)
      @nick   = nick
      @api    = consumer context.opts.api_base
      @stream = consumer context.opts.stream_api_base

      if @@profiles.key? @nick
        token,secret   = @@profiles[@nick]
        @access        = ::OAuth::AccessToken.new(@api, token, secret)
        @stream_access = ::OAuth::AccessToken.new(@stream, token, secret)
      end
    end

    def consumer(url)
      uri = URI(url)
      site = "#{uri.scheme}://#{uri.host}"
      ::OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, {
                              :site => site,
                              :proxy => ENV["HTTP_PROXY"] || ENV["http_proxy"]
                            })
    end

    def verified?
      @access != nil
    end

    def url
      @request = @api.get_request_token
      @request.authorize_url
    end

    def verify(code)
      @access = @request.get_access_token(:oauth_verifier => code)
      if @access then
        @@profiles[@nick] = [ @access.token , @access.secret ]
      end
    rescue
      false
    end
  end
end

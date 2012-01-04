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

    attr_reader :access
    def initialize(context, nick)
      uri = URI(context.opts.api_base)
      site = "#{uri.scheme}://#{uri.host}"
      p site
      @nick  = nick
      @oauth = ::OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, {
                                       :site => site,
                                       :proxy => ENV["HTTP_PROXY"] || ENV["http_proxy"]
                                     })

      if @@profiles.key? @nick
        token,secret = @@profiles[@nick]
        @access = ::OAuth::AccessToken.new(@oauth, token, secret)
      end
    end

    def verified?
      @access != nil
    end

    def url
      @request = @oauth.get_request_token
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

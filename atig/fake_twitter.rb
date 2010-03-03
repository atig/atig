#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "net/https"
require "json"
require 'atig/twitter_struct'
require 'atig/http'

module Atig
  # from tig.rb
  class FakeTwitter
    def initialize(logger,*_)
      @log = logger
    end

    def self.http_methods(*methods)
      methods.each do |m|
        self.module_eval <<END
          def #{m}(path, query = {}, opts = {})
            api path, query, opts
          end
END
      end
    end
    http_methods :get, :post, :put, :delete


    def api(path, query = {}, opts = {})
      path.sub!(%r{\A/+}, "")
      json = File.read(path+".json")


      res = JSON.parse(json)
      TwitterStruct.make(res)
    end
  end
end


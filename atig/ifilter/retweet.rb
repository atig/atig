#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    class Retweet
      def initialize(*_); end

      def call(status)
        return status unless status.retweeted_status
        status.merge :text => "\00310♺ \017#{status.text}"
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    class Retweet
      def initialize(*_); end

      def call(s, status)
        return s unless status.retweeted_status
        "\00310♺ \017#{s}"
      end
    end
  end
end

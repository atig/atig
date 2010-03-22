#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    module Retweet
      Prefix = "\00310♺ \017"
      def self.call(status)
        return status unless status.retweeted_status
        status.merge :text => "#{Prefix}RT: #{status.retweeted_status.text}"
      end
    end
  end
end

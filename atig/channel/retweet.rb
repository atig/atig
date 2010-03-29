#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/channel/channel'

module Atig
  module Channel
    class Retweet < Atig::Channel::Channel
      def initialize(context, gateway, db)
        super

        db.statuses.find_all(:limit=>50).reverse_each do|entry|
          if entry.source == :retweeted_to_me then
            @channel.message entry
          end
        end

        db.statuses.listen do|entry|
          if entry.source == :retweeted_to_me then
            @channel.message entry
          end
        end
      end

      def channel_name; "#retweet" end
    end
  end
end

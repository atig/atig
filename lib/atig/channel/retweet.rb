# -*- mode:ruby; coding:utf-8 -*-
require 'atig/channel/channel'

module Atig
  module Channel
    class Retweet < Atig::Channel::Channel
      def initialize(context, gateway, db)
        super

        db.statuses.find_all(:limit=>50).reverse_each {|entry|
          message entry
        }

        db.statuses.listen {|entry|
          message entry
        }
      end

      def channel_name; "#retweet" end

      def message(entry)
        if entry.status.retweeted_status then
          @channel.message entry
        end
      end
    end
  end
end

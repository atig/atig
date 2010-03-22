#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/channel/channel'
module Atig
  module Channel
    class Mention < Atig::Channel::Channel
      def initialize(context, gateway, db)
        super

        db.statuses.listen do|entry|
          if entry.status.text.include?("@#{db.me.screen_name}")
            @channel.message(entry)
          end
        end
      end

      def channel_name; "#mention" end
    end
  end
end

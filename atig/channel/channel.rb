#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Channel
      def initialize(name, gateway, db)
        @channel = gateway.channel name
        @channel.join_me

        db.statuses.listen do|entry|
          case entry.source
          when :timeline, :me
            @channel.topic entry if entry.user.id == db.me.id
          end
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Channel
      def initialize(context, gateway, db)
        @channel = gateway.channel channel_name, :handler=>self
        @channel.join_me

        db.statuses.listen do|entry|
          case entry.source
          when :timeline, :me
            @channel.topic entry if entry.user.id == db.me.id
          end
        end
      end

      def on_invite(api, nick)
        api.post("friendships/create/#{nick}")
      end

      def on_kick(api, nick)
        api.post("friendships/destroy/#{nick}")
      end
    end
  end
end

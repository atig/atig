#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/channel/channel'
module Atig
  module Channel
    class Timeline < Atig::Channel::Channel
      def initialize(context, gateway, db)
        super

        @channel.notify "Client options: #{context.opts.marshal_dump.inspect}"

        # つないだときに発言がないとさみしいので
        db.statuses.find_all(:limit=>50).reverse_each do|entry|
          case entry.source
          when :timeline, :me
            @channel.message entry
          end
        end

        db.statuses.listen do|entry|
          case entry.source
          when :timeline, :me
            @channel.message entry
          end
        end

        db.followings.listen do|kind, users|
          @channel.send kind,users
        end
      end

      def on_invite(api, nick)
        api.post("friendships/create/#{nick}")
        @db.followings.invalidate
      end

      def on_kick(api, nick)
        api.post("friendships/destroy/#{nick}")
        @db.followings.invalidate
      end

      def on_who(&f)
        @db.followings.users.each(&f)
      end

      def channel_name; "#twitter" end
    end
  end
end

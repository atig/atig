# -*- mode:ruby; coding:utf-8 -*-

require 'atig/channel/channel'
require 'atig/util'
require 'atig/update_checker'

module Atig
  module Channel
    class Timeline < Atig::Channel::Channel
      include Util

      def initialize(context, gateway, db)
        super
        @log = context.log

        @channel.notify "Client options: #{context.opts.marshal_dump.inspect}"

        # つないだときに発言がないとさみしいので
        db.statuses.find_all(:limit=>50).reverse_each do|entry|
          case entry.source
          when :timeline, :me
            @channel.message entry
          end
        end

        # git clone した状態から動かしていたら常に最新版のチェック
        daemon do
          log :info,"check update"
          messages = UpdateChecker.latest
          unless messages.empty?
            @channel.notify "\002New version is available.\017 run 'git pull'."
            messages[0, 3].each do |m|
              @channel.notify "  \002#{m[/.+/]}\017"
            end
            @channel.notify("  ... and more. check it: http://mzp.github.io/atig/") if messages.size > 3
          end
          sleep (3*60*60)
        end if UpdateChecker.git_repos?

        db.statuses.listen do|entry|
          if db.followings.include?(entry.user) or
              entry.source == :timeline or
              entry.source == :user_stream or
              entry.source == :me then
            @channel.message entry
          end
        end

        @channel.send :join, db.followings.users

        db.followings.listen do|kind, users|
          @channel.send(kind, users) if @channel.respond_to?(kind)
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
        return unless f
        @db.followings.users.each(&f)
      end

      def channel_name; "#twitter" end
    end
  end
end

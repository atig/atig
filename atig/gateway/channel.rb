#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'net/irc'

module Atig
  module Gateway
    class Channel
      include Net::IRC::Constants

      MAX_MODE_PARAMS = 3

      def initialize(opts={})
        @session  = opts[:session]
        @name     = opts[:name]
        @filters  = opts[:filters] || []
        @opts     = opts[:opts]
        @prefix   = opts[:prefix]
        @nick     = opts[:nick]
        @handler  = opts[:handler]
      end

      def on_invite(*args)
        @handler && @handler.respond_to?(:on_invite) && @handler.on_invite(*args)
      end

      def on_kick(*args)
        @handler && @handler.respond_to?(:on_kick)   && @handler.on_kick(*args)
      end

      def join_me
        @session.post @prefix, JOIN, @name
        @session.post @session.server_name, MODE, @name, "+mto", @nick
        @session.post @session.server_name, MODE, @name, "+q", @nick
      end

      def part_me(msg)
        @session.post @prefix, PART, @name, msg
      end

      def message(entry, command = PRIVMSG)
        user        = entry.user
        screen_name = user.screen_name
        prefix      = prefix user
        str         = run_filters entry

        @session.post prefix, command, @name, str
      end

      def notify(str)
        @session.post @session.server_name, NOTICE, @name, str.gsub(/\r\n|[\r\n]/, " ")
      end

      def topic(entry)
        str = run_filters entry
        @session.post @prefix, TOPIC, @name, str
      end

      def join(users)
        params = []
        users.each do |user|
          prefix = prefix(user)
          @session.post prefix, JOIN, @name
          case
          when user.protected
            params << ["v", prefix.nick]
          when user.only
            params << ["o", prefix.nick]
          end
          next if params.size < MAX_MODE_PARAMS

          @session.post @session.server_name, MODE, @name, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n}
          params = []
        end
        @session.post @session.server_name, MODE, @name, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n}
      end

      def part(users)
        users.each do|u|
          @session.post prefix(u), PART, @name, ""
        end
      end

      private
      def run_filters(entry)
        status = entry.status.merge(:tid=>entry.tid)
        @filters.inject(status) {|x, f| f.call x }.text
      end

      def prefix(u)
        nick = u.screen_name
        nick = "@#{nick}" if @opts.athack
        user = "id=%.9d" % u.id
        host = "twitter"
        host += "/protected" if u.protected

        Net::IRC::Prefix.new("#{nick}!#{user}@#{host}")
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'net/irc'
require 'time'
require 'atig/command/command'


module Atig
  module Command
    class User < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(user u) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <NICK> [<NUM>]"
          return
        end
        nick, num,*_ = args

        count = 20 unless (1..200).include?(count = num)
        api.delay(0) do|t|
          begin
            statuses = t.get("statuses/user_timeline",
                             { :count => count, :screen_name => nick})
            db.transaction do|d|
              statuses.reverse_each do|status|
                d.statuses.add :status => status, :user => status.user, :source => :user
              end
              db.
                statuses.
                find_by_screen_name(nick, :limit=>count).
                reverse_each do|entry|
                gateway[target].message entry, Net::IRC::Constants::NOTICE
              end
            end
          rescue Twitter::APIFailed => e
            yield e.to_s
          end
        end
      end
    end
  end
end

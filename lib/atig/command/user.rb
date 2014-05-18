# -*- mode:ruby; coding:utf-8 -*-

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

        count = 20 unless (1..200).include?(count = num.to_i)
        api.delay(0) do|t|
          begin
            statuses = t.get("statuses/user_timeline",
                             { count: count, screen_name: nick})
            statuses.reverse_each do|status|
              db.statuses.transaction do|d|
                d.add status: status, user: status.user, source: :user
              end
            end

            db.statuses.
              find_by_screen_name(nick, limit:count).
              reverse_each do|entry|
              gateway[target].message entry, Net::IRC::Constants::NOTICE
            end
          rescue Twitter::APIFailed => e
            yield e.to_s
          end
        end
      end
    end
  end
end

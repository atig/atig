#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'time'
require 'atig/command/command'

module Atig
  module Command
    class Time < Atig::Command::Command
      def command_name; %w(time) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <NICK>"
          return
        end
        nick, *_ = args
        Info.user(db, api, nick){|user|
          offset = user.utc_offset
          time   = "TIME :%s%s (%s)" %  [
                                         (::Time.now + offset).utc.iso8601[0, 19],
                                         "%+.2d:%.2d" % (offset/60).divmod(60),
                                         user.time_zone
                                        ]
          entry = TwitterStruct.make('user'   => user,
                                     'status' => { 'text' =>
                                       Net::IRC.ctcp_encode(time) })
          gateway[target].message entry, Net::IRC::Constants::NOTICE
        }
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/command/info'

module Atig
  module Command
    class Thread < Atig::Command::Command
      def initialize(*args)
        super
      end

      def command_name; %w(thread) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <ID> [<NUM>]"
          return
        end

        tid, num = args
        count = 10 unless (1..20).include?(count = num.to_i)

        if entry = Info.find_status(db, tid) then
          chain(entry,count){|x|
            gateway[target].message x, Net::IRC::Constants::NOTICE
          }
        else
          yield "No such ID : #{tid}"
        end
      end

      def chain(entry,count, &f)
        if count <= 0 then
          return
        elsif id = entry.status.in_reply_to_status_id then
          Info.status(db, api, id){|next_|
            chain(next_, count - 1, &f)
          }
        end
        f.call entry
      end
    end
  end
end

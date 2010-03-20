#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

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
        count = 20 unless (1..20).include?(count = num.to_i)

        if entry = find_by_tid(tid) then
          chain(entry,count){|x|
            gateway[target].message x, Net::IRC::Constants::NOTICE
          }
        else
          yield "No such ID : #{tid}"
        end
      end

      def chain(entry,count, &f)
        return if count <= 0
        f.call entry
        if id = entry.status.in_reply_to_status_id then
          if next_ = db.statuses.find_by_id(id) then
            chain(next_, count - 1, &f)
          else
            api.delay(0) do|t|
              status = t.get "statuses/show/#{id}"
              db.transaction do|d|
                d.statuses.add :status => status, :user => status.user, :source => :thread
                next_ = db.statuses.find_by_id(id)
                chain(next_, count - 1, &f)
              end
            end
          end
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Reply < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(mention re reply) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <ID> blah blah"
          return
        end

        tid = args.first
        if status = find_by_tid(tid) then
          text = mesg.split(" ", 3)[2]
          name = status.user.screen_name

          text = "@#{name} #{text}" if text.nil? or not text.include?(name)

          q = gateway.output_message(:status => text,
                                     :in_reply_to_status_id => status.id)

          api.delay(0) do|t|
            ret = t.post("statuses/update", q)
            gateway.update_status ret, target, "In reply to #{tid}: #{status.text}"
          end
        end
      end
    end
  end
end

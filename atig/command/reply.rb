#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/command/info'

module Atig
  module Command
    class Reply < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(mention re reply) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <ID_or_SCREEN_NAME> blah blah"
          return
        end

        tid = args.first
        if entry = Info.find_status(db,tid) then
          text = mesg.split(" ", 3)[2]
          name = entry.user.screen_name

          text = "@#{name} #{text}" if text.nil? or not text.include?("@#{name}")

          q = gateway.output_message(:status => text,
                                     :in_reply_to_status_id => entry.status.id)

          api.delay(0) do|t|
            ret = t.post("statuses/update", q)
            gateway.update_status ret, target, "In reply to #{name}: #{entry.status.text}"
          end
        else
          yield "No such ID : #{tid}"
        end
      end
    end
  end
end

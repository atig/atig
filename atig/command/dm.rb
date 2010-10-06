#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
begin
  require 'jcode'
rescue LoadError
end

module Atig
  module Command
    class Dm < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(d dm dms) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <SCREEN_NAME> blah blah"
          return
        end
        user = args.first
        text = mesg.split(" ", 3)[2]
        api.delay(0) do|t|
          t.post("direct_messages/new",{
                   :user => user,
                   :text => text
                 })
          yield "Sent message to #{user}: #{text}"
        end
      end
    end
  end
end

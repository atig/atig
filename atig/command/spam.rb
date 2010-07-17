#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/command/info'

module Atig
  module Command
    class Spam < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(spam SPAM) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <SCREEN_NAME1> <SCREEN_NAME2> ..."
          return
        else
          args.each do|screen_name|
            api.delay(0) do|t|
              res = t.post("report_spam",:screen_name => screen_name)
              yield "Report #{res.screen_name} as SPAMMER"
            end
          end
        end
      end
    end
  end
end

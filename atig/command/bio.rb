#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Bio < Atig::Command::Command
      def initialize(*args); super end
      def command_name; "bio" end

      def action(target, mesg, command,args)
        if args.empty?
          yield "/me #{command} <ID>"
          return
        end
        nick,*_ = args

        api.delay(0) do|t|
          user = t.get("users/show", { :screen_name => nick})
          yield user.description
        end
      end
    end
  end
end

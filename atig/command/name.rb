#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Name < Atig::Command::Command
      def command_name; %w(name) end

      def action(target, mesg, command, args)
        api.delay(0) do|t|
          name = mesg.split(" ", 2)[1] || ""
          t.post('account/update_profile',:name=>name)
          yield "You are named #{name}."
        end
      end
    end
  end
end

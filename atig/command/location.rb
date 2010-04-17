#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Location < Atig::Command::Command
      def command_name; %w(in location loc) end

      def action(target, mesg, command, args)
        api.delay(0) do|t|
          location = mesg.split(" ", 2)[1] || ""
          t.post('account/update_profile',:location=>location)

          if location.empty? then
            yield "You are nowhere now."
          else
            yield "You are in #{location} now."
          end
        end
      end
    end
  end
end

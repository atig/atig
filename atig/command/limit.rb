#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/command'

module Atig
  module Command
    class Limit < Atig::Command::Command
      def command_name; %w(rls limit limits) end

      def action(target, mesg, command, args)
        yield "#{api.remain} / #{api.limit} (reset at #{::Time.at(api.reset).strftime('%Y-%m-%d %H:%M:%S')})"
      end
    end
  end
end

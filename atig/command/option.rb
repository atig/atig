#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/command'
require 'atig/option'

module Atig
  module Command
    class Option < Atig::Command::Command
      def command_name; %w(opt opts option options) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <name> [<value>]"
          return
        end

        name, value, *_ = args
        unless value then
          # show the value
          yield "#{name} => #{@opts.send name}"
        else
          # set the value
          @opts.send "#{name}=",::Atig::Option.parse_value(value)
          yield "#{name} => #{@opts.send name}"
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'time'
require 'atig/command/command'
require 'atig/command/info'

module Atig
  module Command
    class Destroy < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(destroy remove rm) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <ID1> <ID2> ..."
          return
        end
        args.each do|tid|
          if entry = Info.find_status(db, tid)
            if entry.user.id == db.me.id
              api.delay(0) do|t|
                res = t.post("statuses/destroy/#{entry.status.id}")
                yield "Destroyed: #{entry.status.text}"
              end
            else
              yield "The status you specified by the ID tid is not yours."
            end
          else
            yield "No such ID tid"
          end
        end
      end
    end
  end
end

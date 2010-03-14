#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Favorite < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %r/\A(un)?fav\z/ end

      def action(target, mesg, command, args)
        method   = command[1].nil? ? "create" : "destroy"
        force    = !!command[2]
        entered  = command[0].capitalize
        p command
        p method
        args.each do|tid|
          if entry = find_by_tid(tid)
            api.delay(0){|t|
              res = t.post("favorites/#{method}/#{entry.id}")
              yield "#{entered}: #{res.user.screen_name}: #{res.text}"
            }
          else
            yield "No such ID : #{tid}"
          end
        end
      end
    end
  end
end

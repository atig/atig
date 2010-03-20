#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'

module Atig
  module Command
    class Favorite < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(fav unfav) end

      def action(target, mesg, command, args)
        method   = { 'fav' => 'create', 'unfav' => 'destroy' }[command]

        args.each do|tid|
          if entry = find_by_tid(tid)
            api.delay(0){|t|
              res = t.post("favorites/#{method}/#{entry.status.id}")
              yield "#{command.upcase}: #{entry.user.screen_name}: #{entry.status.text}"
            }
          else
            yield "No such ID : #{tid}"
          end
        end
      end
    end
  end
end

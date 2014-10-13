# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/command/info'

module Atig
  module Command
    class Favorite < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(fav unfav) end

      def action(target, mesg, command, args)
        method   = { 'fav' => 'create', 'unfav' => 'destroy' }[command]

        args.each do|tid|
          if entry = Info.find_status(db, tid)
            api.delay(0){|t|
              t.post("favorites/#{method}", {id: entry.status.id})
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

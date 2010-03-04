#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/command/single_action'

module Atig
  module Command
    class Favorite < SingleAction
      def initialize(gateway)
        super(gateway,[ %r/\A(un)?fav(?:ou?rite)?(!)?\z/ ])
        @favorites = []
      end

      def action(target, mesg, command, args)
        # fav, unfav, favorite, unfavorite, favourite, unfavourite
        method   = command[1].nil? ? "create" : "destroy"
        force    = !!command[2]
        entered  = command[0].capitalize
        entries  = []

        args.each do |tid|
          if entry = find_by_tid(tid)
            entries << entry
          else
            # PRIVMSG: fav nick
            notify "No such ID : #{tid}"
          end

          entries.each do|e|
            if not force and method == "create" and
                @favorites.find {|i| i.id == e.id }
              notify "The status is already favorited! <#{gateway.permalink(e)}>"
              next
            end

            gateway.api.delay(0){|t|
              begin
                res = t.post("favorites/#{method}/#{e.id}")
                notify "#{entered}: #{entry.user.screen_name}: #{gateway.input_message(entry)}"
                if method == "create"
                  @favorites << res
                else
                  @favorites.delete_if {|i| i.id == res.id }
                end
              rescue => e
                notify e.inspect
                raise e
              end
            }
          end
        end
      end
    end
  end
end

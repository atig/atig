#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class List
      class Handler
        def initialize(db, name)
          @db   = db
          @name = name
        end

        def on_invite(api, nick)
          api.post("#{@db.me.screen_name}/#{@name}/members", :id => nick )
          @db.lists.invalidate @name
        end

        def on_kick(api, nick)
          api.delete("#{@db.me.screen_name}/#{@name}/members", :id => nick )
          @db.lists.invalidate @name
        end
      end

      def initialize(context, gateway, db)
        @channels = Hash.new do|hash,name|
          channel = gateway.channel "##{name}", :handler => Handler.new(db, name)
          channel.join_me
          hash[name] = channel
        end

        db.statuses.listen do|entry|
          case entry.source
          when :timeline, :me
            lists = db.lists.find_by_screen_name(entry.user.screen_name)
            lists.each{|name|
              @channels[name].message entry
            }
          when :list
            @channels[entry.list].message entry
          end
        end

        db.statuses.listen do|entry|
          case entry.source
          when :timeline, :me
            if entry.user.id == db.me.id
              @channels.each{|_,channel|
                channel.topic entry
              }
            end
          end
        end

        db.lists.listen do|kind, name, users|
          case kind
          when :new
            @channels[name].join_me
          when :del
            @channels[name].part_me "No longer follow the list #{name}"
          when :join
            @channels[name].join users
          when :part
            @channels[name].part users
          when :mode
          end
        end
      end
    end
  end
end

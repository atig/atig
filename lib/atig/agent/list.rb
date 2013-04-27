# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class List
      include Util

      def initialize(context, api, db)
        @log = context.log
        @db  = db
        log :info, "initialize"

        @db.lists.on_invalidated{|name|
          log :info, "invalidated #{name}"
          api.delay(0){|t|
            if name == :all then
              full_update t
            else
              @db.lists[name].update t.page("#{@db.me.screen_name}/#{name}/members", :users, true)
            end
          }
        }
        api.repeat( interval ) do|t|
          self.full_update t
        end
      end

      def full_update(t)
        lists = entry_points.map{|entry|
          t.get(entry)
        }.flatten.compact

        users = {}
        lists.map do |list|
          name = if list.user.screen_name == @db.me.screen_name then
                   "#{list.slug}"
                 else
                   "#{list.user.screen_name}^#{list.slug}"
                 end
          begin
            users[name] =
              t.page("lists/members", :users, {:owner_screen_name => list.user.screen_name, :slug => list.slug})
          rescue => e
            log :error, e.inspect
            users[name] =
              @db.lists.find_by_list_name(list.slug)
          end
        end
        @db.lists.update users
      end
    end
  end
end

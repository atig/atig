#! /opt/local/bin/ruby -w
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

        api.repeat(3600) do|t|
          lists = t.page("#{@db.me.screen_name}/lists", :lists, true)
          users = {}
          lists.map do|list|
            name = if list.user.screen_name == @db.me.screen_name then
                     "#{list.slug}"
                   else
                     "#{list.user.screen_name}^#{list.slug}"
                   end
            begin
              users[name] =
                t.page("#{@db.me.screen_name}/#{list.slug}/members", :users, true)
            rescue APIFailed => e
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
end

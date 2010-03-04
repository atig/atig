#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'

module Atig
  module Db
    class Lists
      include Listenable

      def initialize
        @lists   = {}
      end

      def update(lists)
        @members = Hash.new{|hash,key|
          hash[key] = []
        }

        (lists.keys  - @lists.keys).each do|name|
          users = lists[name]
          list = Followings.new
          list.listen{|kind,users| notify kind,name,users }
          @lists[name] = list
          notify :new, name
        end

        (@lists.keys - lists.keys).each do|x|
          @lists.delete x
          notify :del,x
        end

        lists.each do|name,users|
          @lists[name].update users
        end

        lists.each do|list, users|
          users.each do|user|
            @members[user.screen_name] << list
          end
        end
      end

      def find_by_screen_name(name)
        return [] unless @members
        @members[name]
      end

      def find_by_list_name(name)
        @lists[name].users
      end
    end
  end
end
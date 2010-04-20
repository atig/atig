#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'

module Atig
  module Db
    class Lists
      include Listenable

      def initialize(name)
        @name    = name
        @lists   = {}
        @on_invalidated = lambda{|*_| }
        @members = nil
      end

      def update(lists)
        @members = Hash.new{|hash,key|
          hash[key] = []
        }

        (lists.keys  - @lists.keys).each do|name|
          list = Followings.new(@name % name)
          list.listen{|kind,users|
            notify kind,name,users
          }
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

      def [](name)
        @lists[name]
      end

      def invalidate(name)
        @on_invalidated.call name
      end

      def on_invalidated(&f)
        @on_invalidated = f
      end

      def find_by_screen_name(name)
        return [] unless @members
        @members[name]
      end

      def find_by_list_name(name)
        @lists[name].users
      end

      def each(&f)
        @lists.each do|name,users|
          f.call name,users.users
        end
      end
    end
  end
end

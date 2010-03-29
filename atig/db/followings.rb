#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'

module Atig
  module Db
    class Followings
      include Listenable
      attr_reader :users


      def initialize
        @users = []
        @on_invalidated = lambda{}
      end

      def size; @users.size end
      def empty?; @users.empty? end

      def invalidate
        @on_invalidated.call
      end

      def on_invalidated(&f)
        @on_invalidated = f
      end

      def update(users)
        bye   = diff(@users,users ){|x,y| x.screen_name == y.screen_name }
        join  = diff(users ,@users){|x,y| x.screen_name == y.screen_name }
        mode  = users.select{|user|
          @users.any?{|u|
            user.screen_name == u.screen_name &&
            (user.protected != u.protected || user.only != u.only)
          }
        }

        notify(:part, bye)  unless bye  == []
        notify(:join, join) unless join == []
        notify(:mode, mode) unless mode == []

        @users = users
      end

      def find_by_screen_name(name)
        @users.find{|u| u.screen_name == name }
      end

      def include?(user)
        @users.find{|u| u.id == user.id }
      end

      private
      def diff(xs, ys, &f)
        xs.select{|x| not ys.any?{|y| f.call(x,y) } }
      end
    end
  end
end

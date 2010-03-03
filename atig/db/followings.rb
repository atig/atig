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

        notify(:bye , bye)  unless bye  == []
        notify(:join, join) unless join == []
        notify(:mode, mode) unless mode == []

        @users = users
      end

      private
      def diff(xs, ys, &f)
        xs.select{|x| not ys.any?{|y| f.call(x,y) } }
      end
    end
  end
end

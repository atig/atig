#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'
require 'atig/db/sql'

module Atig
  module Db
    class Followings
      include Listenable
      attr_reader :users

      def initialize(name)
        @db = Sql.new name

        unless File.exist? name then
          @db.execute do|db|
            db.execute %{create table users (
                          id integer primary key,
                          screen_name text,
                          user_id text,
                          protected bool,
                          only bool,
                          data blob);}
          end
        end

        @users = []
        @on_invalidated = lambda{}
      end

      def size
        @db.execute do|db|
          db.get_first_value('SELECT COUNT(*) FROM users').to_i
        end
      end
      def empty?; @users.empty? end

      def invalidate
        @on_invalidated.call
      end

      def on_invalidated(&f)
        @on_invalidated = f
      end

      def update(users)
        names = users.map{|u| u.screen_name.inspect }.join(",")
        bye = join = []
        @db.execute do|db|
          # join
          db.execute("SELECT screen_name,data FROM users WHERE screen_name NOT IN (#{names})").each do|_,_|
          end

          # part
          db.execute("SELECT screen_name,data FROM users WHERE screen_name NOT IN (#{names})").each do|_,data|
            notify :part, @db.load(data)
          end
        end

        @db.execute do|db|
          users.each do|user|
            id = db.get_first_value('SELECT id FROM users WHERE user_id = ? LIMIT 1', user.id)
            if id then
              db.execute("UPDATE users SET screen_name = ?, protected = ?, only = ?, data = ? WHERE id = ?",
                         user.screen_name,
                         user.protected,
                         user.only,
                         @db.dump(user),
                         id)
            else
              db.execute("INSERT INTO users
                          VALUES(NULL, :screen_name, :user_id, :protected, :only, :data)",
                         :screen_name => user.screen_name,
                         :user_id     => user.id,
                         :protected   => user.protected,
                         :only        => user.only,
                         :data        => @db.dump(user))
            end
          end
        end

        # bye   = diff(@users,users ){|x,y| x.screen_name == y.screen_name }
        # join  = diff(users ,@users){|x,y| x.screen_name == y.screen_name }
        # mode  = users.select{|user|
        #   @users.any?{|u|
        #     user.screen_name == u.screen_name &&
        #     (user.protected != u.protected || user.only != u.only)
        #   }
        # }

        #        notify(:part, bye)  unless bye  == []
        #        notify(:join, join) unless join == []
        #        notify(:mode, mode) unless mode == []

        #        @users = users
      end

      def find_by_screen_name(name)
        @db.execute do|db|
          @db.load db.get_first_value('SELECT data FROM users WHERE screen_name = ? LIMIT 1', name)
        end
      end

      def include?(user)
        @db.execute do|db|
          db.get_first_value('SELECT data FROM users WHERE user_id = ? LIMIT 1', user.id) != nil
        end
      end
    end
  end
end

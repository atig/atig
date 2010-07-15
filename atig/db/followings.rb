#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'
require 'atig/db/transaction'
require 'atig/db/sql'

module Atig
  module Db
    class Followings
      include Listenable
      include Transaction

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
            db.execute %{
              create index users_screen on users (screen_name);
            }
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

      def empty?
        @db.execute do|db|
          db.get_first_value('SELECT * FROM users LIMIT 1') == nil
        end
      end

      def invalidate
        @on_invalidated.call
      end

      def on_invalidated(&f)
        @on_invalidated = f
      end

      def users
        @db.execute{|db|
          db.execute("SELECT data FROM users").map{|data|
            @db.load data[0]
          }
        }
      end

      def exists?(db, templ, *args)
        db.get_first_value("SELECT * FROM users WHERE #{templ} LIMIT 1",*args) != nil
      end

      def may_notify(mode, xs)
        unless xs.empty? then
          notify mode, xs
        end
      end

      def update(users)
        @db.execute do|db|
          may_notify :join, users.select{|u|
            not exists?(db,
                        "screen_name = ?",
                        u.screen_name)
          }

          names = users.map{|u| u.screen_name.inspect }.join(",")
          parts =
          may_notify :part, db.execute(%{SELECT screen_name,data FROM users
                                         WHERE screen_name NOT IN (#{names})}).map{|_,data|
            @db.load(data)
          }
          db.execute(%{DELETE FROM users
                       WHERE screen_name NOT IN (#{names})})

          may_notify :mode, users.select{|u|
            exists?(db,
                    "screen_name = ? AND (protected != ? OR only != ?)",
                    u.screen_name, u.protected, u.only)
          }

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
      end

      def find_by_screen_name(name)
        @db.execute do|db|
          @db.load db.get_first_value('SELECT data FROM users WHERE screen_name = ? LIMIT 1', name)
        end
      end

      def include?(user)
        @db.execute do|db|
          exists? db,'user_id = ?', user.id
        end
      end
    end
  end
end

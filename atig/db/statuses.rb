#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/listenable'
require 'sqlite3'
require 'atig/db/roman'
require 'base64'

class OpenStruct
  def id; method_missing(:id) end
end

module Atig
  module Db
    class Statuses
      include Listenable

      def initialize(name)
        @db_name = name
        @id    = 0
        @roman = Roman.new

        unless File.exist? name then
          execute do|db|
            db.execute %{create table status (
                          id   text,
                          tid  text,
                          screen_name text,
                          user_id     text,
                          created_at  text,
                          data blob);}
          end
        end
      end

      def add(opt)
        entry = OpenStruct.new opt.merge(:id  => opt[:status].id,
                                         :tid => @roman.make(@id))
        execute do|db|
          return unless db.execute(%{SELECT id FROM status WHERE id = ?}, entry.id).empty?

          db.execute(%{INSERT INTO status
                      VALUES(:id, :tid, :screen_name, :user_id, :created_at, :data)},
                     :id          => entry.id,
                     :tid         => entry.tid,
                     :screen_name => opt[:user].screen_name,
                     :user_id     => opt[:user].id,
                     :created_at  => opt[:status].created_at,
                     :data        => [Marshal.dump(entry)].pack('m'))
          @id += 1
          notify entry
        end
      end

      def find_by_screen_name(name, opt={})
        find 'screen_name',name, opt
      end

      def find_by_user(user, opt={})
        find 'user_id', user.id, opt
      end

      def find_by_tid(tid)
        find('tid', tid).first
      end

      def find_by_id(id)
        find('id', id).first
      end

      private
      def find(lhs,rhs, opt={},&f)
        res = []
        execute do|db|
          db.execute("SELECT data FROM status WHERE #{lhs} = ? ORDER BY created_at DESC LIMIT ?",
                     rhs,opt.fetch(:limit,20)) do|data,*_|
            res << Marshal.load(data.unpack('m').first)
          end
        end
        res
      end

      def execute(&f)
        db = SQLite3::Database.new @db_name
        begin
          res = f.call db
        ensure
          db.close
        end
        res
      end
    end
  end
end

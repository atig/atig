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
        @roman = Roman.new

        unless File.exist? name then
          execute do|db|
            db.execute %{create table status (
                          id integer primary key,
                          status_id   text,
                          tid  text,
                          sid  text,
                          screen_name text,
                          user_id     text,
                          created_at  integer,
                          data blob);}
            db.execute %{create table id (
                          id integer primary key,
                          screen_name text,
                          count integer);}
          end
        end
      end

      def add(opt)
        execute do|db|
          id  = opt[:status].id
          return unless db.execute(%{SELECT id FROM status WHERE status_id = ?}, id).empty?

          screen_name = opt[:user].screen_name
          sum   = db.get_first_value("SELECT sum(count) FROM id").to_i
          count = db.get_first_value("SELECT count      FROM id WHERE screen_name = ?", screen_name).to_i
          entry = OpenStruct.new opt.merge(:tid => @roman.make(sum),
                                           :sid => "#{screen_name}:#{@roman.make(count)}")
          db.execute(%{INSERT INTO status
                      VALUES(NULL, :id, :tid, :sid, :screen_name, :user_id, :created_at, :data)},
                     :id          => id,
                     :tid         => entry.tid,
                     :sid         => entry.sid,
                     :screen_name => screen_name,
                     :user_id     => opt[:user].id,
                     :created_at  => Time.parse(opt[:status].created_at).to_i,
                     :data        => [Marshal.dump(entry)].pack('m'))
          if count == 0 then
            db.execute("INSERT INTO id VALUES(NULL,?,?)", screen_name, 1)
          else
            db.execute("UPDATE id SET count = ? WHERE screen_name = ?", count + 1, screen_name)
          end

          notify entry
        end
      end

      def find_all(opt={})
        find '1', 1, opt
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

      def find_by_sid(tid)
        find('sid', tid).first
      end

      def find_by_status_id(id)
        find('status_id', id).first
      end

      def find_by_id(id)
        find('id', id).first
      end

      def remove_by_id(id)
        execute do|db|
          db.execute "DELETE FROM status WHERE id = ?",id
        end
      end

      private
      def find(lhs,rhs, opt={},&f)
        query  = "SELECT id,data FROM status WHERE #{lhs} = :rhs ORDER BY created_at DESC LIMIT :limit"
        params = { :rhs => rhs, :limit => opt.fetch(:limit,20) }
        res = []
        execute do|db|
          db.execute(query,params) do|id,data,*_|
            e = Marshal.load(data.unpack('m').first)
            e.id = id.to_i
            res << e
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

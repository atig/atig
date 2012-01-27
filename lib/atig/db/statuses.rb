# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/listenable'
require 'atig/db/transaction'
require 'rubygems'
require 'sqlite3'
require 'atig/db/roman'
require 'atig/db/sql'
require 'base64'

class OpenStruct
  def id; method_missing(:id) end
end

module Atig
  module Db
    class Statuses
      include Listenable
      include Transaction

      Size = 400

      def initialize(name)
        @db = Sql.new name
        @roman = Roman.new

        unless File.exist? name then
          @db.execute do|db|
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

            # thx to @L_star
            # http://d.hatena.ne.jp/mzp/20100407#c
            db.execute_batch %{
              create index status_createdat on status(created_at);
              create index status_sid on status(sid);
              create index status_statusid on status(status_id);
              create index status_tid on status(tid);
              create index status_userid on status(user_id);

              create index status_id on status(id);
              create index id_id on id(id);
            }
          end
        end
      end

      def add(opt)
        @db.execute do|db|
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
                     :data        => @db.dump(entry))
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
        @db.execute do|db|
          db.execute "DELETE FROM status WHERE id = ?",id
        end
      end

      def cleanup
        @db.execute do|db|
          created_at = db.execute("SELECT created_at FROM status ORDER BY created_at DESC LIMIT 1 OFFSET ?", Size-1)
          unless created_at.empty? then
            db.execute "DELETE FROM status WHERE created_at < ?", created_at.first
          end
          db.execute "VACUUM status"
        end
      end

      private
      def find(lhs,rhs, opt={},&f)
        query  = "SELECT id,data FROM status WHERE #{lhs} = :rhs ORDER BY created_at DESC LIMIT :limit"
        params = { :rhs => rhs, :limit => opt.fetch(:limit,20) }
        res = []

        @db.execute do|db|
          db.execute(query,params) do|id,data,*_|
            e = @db.load(data)
            e.id = id.to_i
            res << e
          end
        end
        res
      end
    end
  end
end

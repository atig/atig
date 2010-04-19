#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/listenable'
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
          end
        end
      end

      def add(opt)
        @db.execute do|db|
          id  = opt[:status].id
          return unless db.execute(%{SELECT id FROM status WHERE status_id = ?}, id).empty?

          screen_name = opt[:user].screen_name
          tid = @roman.make db.get_first_value("SELECT count(*) FROM status").to_i
          sid = @roman.make db.get_first_value("SELECT count(*) FROM status WHERE screen_name = ?", screen_name).to_i
          entry = OpenStruct.new opt.merge(:id  => id, :tid => tid, :sid => "#{screen_name}:#{sid}")
          db.execute(%{INSERT INTO status
                      VALUES(NULL, :id, :tid, :sid, :screen_name, :user_id, :created_at, :data)},
                     :id          => entry.id,
                     :tid         => entry.tid,
                     :sid         => entry.sid,
                     :screen_name => screen_name,
                     :user_id     => opt[:user].id,
                     :created_at  => Time.parse(opt[:status].created_at).to_i,
                     :data        => [Marshal.dump(entry)].pack('m'))
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

      def find_by_id(id)
        find('status_id', id).first
      end

      private
      def find(lhs,rhs, opt={},&f)
        query  = "SELECT data FROM status WHERE #{lhs} = :rhs ORDER BY created_at DESC LIMIT :limit"
        params = { :rhs => rhs, :limit => opt.fetch(:limit,20) }
        res = []
        @db.execute do|db|
          db.execute(query,params) do|data,*_|
            res << Marshal.load(data.unpack('m').first)
          end
        end
        res
      end
    end
  end
end

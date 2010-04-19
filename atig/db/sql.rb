#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'sqlite3'

module Atig
  module Db
    class Sql
      def initialize(name)
        @name = name
      end

      def execute(&f)
        db = SQLite3::Database.new @name
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

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'

module Atig
  module Db
    class Searches
      include Enumerable
      include Listenable

      def initialize
        @searches = []
      end

      def each(&f)
        @lists.each do|name,users|
          f.call name,users.users
        end
      end

      def update(searches)
        parts = diff(@searches, searches ){|x,y| x.id == y.id }
        joins = diff(searches , @searches){|x,y| x.id == y.id }

        parts.each{|c| notify :part, c }
        joins.each{|c| notify :join, c }

        @searches = searches
      end

      private
      def diff(xs, ys, &f)
        xs.select{|x| not ys.any?{|y| f.call(x,y) } }
      end
    end
  end
end

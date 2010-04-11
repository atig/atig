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
        bye   = diff(@searches, searches ){|x,y| x.id == y.id }
        join  = diff(searches , @searches){|x,y| x.id == y.id }


        notify(:part, bye)  unless bye  == []
        notify(:join, join) unless join == []

        @searches = searches
      end

      private
      def diff(xs, ys, &f)
        xs.select{|x| not ys.any?{|y| f.call(x,y) } }
      end
    end
  end
end

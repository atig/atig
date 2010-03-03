#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/listenable'
require 'atig/db/sized_uniq_array'
require 'atig/db/roman'

module Atig
  module Db
    class Statuses
      include Listenable

      def initialize(size)
        @queue = SizedUniqArray.new size
        @roman = Roman.new
      end

      def size; @queue.size end

      def add(opt)
        entry = OpenStruct.new opt.merge(:id => opt[:status].id)

        if i = @queue.push(entry) then
          entry.tid = @roman.make i
          notify entry
        end
      end

      def find_by_screen_name(name, opt={})
        find(opt){|s| s.user.screen_name == name }
      end

      def find_by_user(user, opt={})
        find(opt){|s| s.user == user }
      end

      def find_by_tid(tid)
        @queue[@roman[tid]]
      end

      def find_by_id(id)
        @queue.find{|status| status.id == id }
      end

      private
      def find(opt={},&f)
        statuses = []

        g = if opt[:limit] then
              lambda {|s|
                break if opt[:limit] <= statuses.size
                statuses << s if f.call(s)
              }
            else
              lambda{|s| statuses << s if f.call(s) }
            end

        @queue.reverse_each(&g)
        statuses
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/listenable'
require 'atig/db/sized_uniq_array'

module Atig
  module Db
    class Statuses
      include Listenable

      def initialize(size)
        @queue = SizedUniqArray.new size
      end

      def add(*_)
      end

      def find_by_screen_name(*_)
      end

      def find_by_user(*_)
      end

      def find_by_tid(*_)
      end

      def find_by_id(*_)
      end

      def size; 4 end
    end
  end
end

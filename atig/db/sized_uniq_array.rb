#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'forwardable'
module Atig
  module Db
    class SizedUniqArray
      extend Forwardable
      include Enumerable
      def_delegators :@xs,:[],:each

      def initialize(size)
        @size = size
        @index = 0
        @xs = []
      end

      def include?(x)
        @xs.any?{|item| item.id == x.id }
      end

      def index(s)
        @xs.index(s)
      end

      def push(status)
        @xs[@index] = status
        @index = (@index + 1) % @size
      end
      alias_method :<<, :push
    end
  end
end

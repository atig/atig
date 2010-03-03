#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'forwardable'
module Atig
  module Db
    class SizedUniqArray
      extend Forwardable
      include Enumerable
      def_delegators :@xs,:[]

      def initialize(size)
        @size = size
        @index = 0
        @xs = []
      end

      def each(&f)
      end

      def push(status)
        i = @index
        @xs[i] = status
        @index = (i + 1) % @size
      end
      alias_method :<<, :push
    end
  end
end

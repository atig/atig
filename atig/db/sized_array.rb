#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
module Atig
  module Db
    class SizedUniqArray
      def initialize(size)
        @size = size
        @index = 0
        @xs = []
        @seq = Roman
        @tid = {}
      end

      def include?(id)
        @xs.any?{|item| item.id == id }
      end

      def index(s)
        @xs.index(s)
      end

      def push(status)
        tid = generate @index
        status[:tid] = tid
        @tid[tid] = @xs[@index] = status
        @index = (@index + 1) % @size
      end
      alias_method :<<, :push

      def [](tid)
        @tid[tid]
      end

      private
      def generate(n)
        ret = []
        begin
          n, r = n.divmod(@seq.size)
          ret << @seq[r]
        end while n > 0
        ret.reverse.join #.gsub(/n(?=[bmp])/, "m")
      end
    end
  end
end

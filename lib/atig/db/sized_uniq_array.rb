# -*- mode:ruby; coding:utf-8 -*-

require 'forwardable'

module Atig
  module Db
    class SizedUniqArray
      extend Forwardable
      include Enumerable
      def_delegators :@xs,:[]

      attr_reader :size

      def initialize(capacity)
        @size     = 0
        @index    = 0
        @capacity = capacity
        @xs       = Array.new(capacity, nil)
      end

      def each(&f)
        if @size < @capacity then
          0.upto(@size - 1) {|i|
            f.call @xs[i]
          }
        else
          0.upto(@size - 1){|i|
            f.call @xs[ (i + @index) % @capacity ]
          }
        end
      end

      def reverse_each(&f)
        if @size < @capacity then
          (@size - 1).downto(0) {|i|
            f.call @xs[i]
          }
        else
          (@size - 1).downto(0){|i|
            f.call @xs[ (i + @index) % @capacity ]
          }
        end
      end

      def include?(item)
        self.any?{|x|
          x.id == item.id
        }
      end

      def push(item)
        return nil if include? item
        i = @index
        @xs[i] = item
        @size = [ @size + 1, @capacity ].min
        @index = ( @index + 1 ) % @capacity
        i
      end
      alias_method :<<, :push
    end
  end
end

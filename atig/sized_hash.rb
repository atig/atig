# -*- mode:ruby; coding:utf-8 -*-
require 'forwardable'

module Atig
  class SizedHash
    extend Forwardable

    def_delegators :@xs, :size

    def initialize(size)
      @size = size
      @xs   = []
    end

    def [](key)
      kv = @xs.assoc(key)
      if kv then
        @xs.delete kv
        @xs.push   kv
        kv[1]
      end
    end

    def []=(key,value)
      @xs.push [key, value]
      @xs.shift if @xs.size > @size
    end

    def key?(key)
      @xs.any?{|k,_| key == k }
    end
  end
end

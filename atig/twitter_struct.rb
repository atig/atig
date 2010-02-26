#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
#

module Atig
  # from tig.rb
  class TwitterStruct
    def self.make(obj)
      case obj
      when Hash
        obj = obj.dup
        obj.each do |k, v|
          obj[k] = TwitterStruct.make(v)
        end
        TwitterStruct.new(obj)
      when Array
        obj.map {|i| TwitterStruct.make(i) }
      else
        obj
      end
    end

    def initialize(obj)
      @obj = obj
    end

    def id
      @obj["id"]
    end

    def [](name)
      @obj[name.to_s]
    end

    def []=(name,val)
      @obj[name.to_s] = val
    end

    def hash
      self.id ? self.id.hash : super
    end

    def eql?(other)
      self.hash == other.hash
    end

    def ==(other)
      self.hash == other.hash
    end

    def method_missing(sym, *args)
      # XXX
      @obj[sym.to_s]
    end
  end
end

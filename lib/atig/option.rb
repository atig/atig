# -*- coding: utf-8 -*-
module Atig
  class Option
    class << self
      def default_value(name, value)
        @default ||= {}
        @default[name.to_sym] = value
      end

      def parse(str)
        @default ||= {}
        opts = str.split(" ")
        opts = opts.inject({}) do |r, i|
          key, value = i.split("=", 2)

          r.update key.to_sym => parse_value(value)
        end
        self.new(@default.merge(opts))
      end

      def parse_value(value)
        case value
        when nil, /\Atrue\z/          then true
        when /\Afalse\z/              then false
        when /\A\d+\z/                then value.to_i
        when /\A(?:\d+\.\d*|\.\d+)\z/ then value.to_f
        else                               value
        end
      end
    end

    default_value :api_base,        'https://api.twitter.com/1/'
    default_value :stream_api_base, 'https://userstream.twitter.com/2/'
    default_value :search_api_base, 'http://search.twitter.com/'

    def initialize(table)
      @table = {}
      table.each do|key,value|
        key = key.to_sym
        @table[key] = value
        new_ostruct_member key
      end

      # Ruby 1.8だとidというフィールドが作れないので作っておく
      new_ostruct_member :id, true
    end

    def marshal_dump; @table end
    def fields;
      @table.keys
    end

    def [](name)
      @table[name.to_sym]
    end

    def []=(name, value)
      @table[name.to_sym] = value
    end

    def new_ostruct_member(name, force=false)
      if force or (not self.respond_to?(name))
        class << self; self; end.class_eval do
          define_method(name) { @table[name] }
          define_method(:"#{name}=") { |x| @table[name] = x }
        end
      end
    end

    def method_missing(mid, *args) # :nodoc:
      mname = mid.id2name
      len = args.length
      if mname =~ /=$/
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
        if self.frozen?
          raise TypeError, "can't modify frozen #{self.class}", caller(1)
        end
        name = mname.chop.to_sym
        @table[name] = args[0]
        self.new_ostruct_member(name)
      elsif len == 0
        @table[mid]
      else
        raise NoMethodError, "undefined method `#{mname}' for #{self}", caller(1)
      end
    end
  end
end

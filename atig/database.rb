#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'thread'
require 'set'

module Atig
  class Database
    include Util
    def initialize(logger)
      @log = logger
      log :info, "initialize"

      @db = Hash.new do| hash, key |
        hash[key] = []
      end


      @listeners =  Hash.new do| hash, key |
        hash[key] = []
      end

      @queue = SizedQueue.new 10
      daemon do
        @updated = Set.new
        f = @queue.pop
        log :debug, "transaction is poped"

        f.call self

        log :debug, "transaction is finished"
      end
    end

    def listen(kind, &f)
      @listeners[kind] << f
    end

    def transaction(&f)
      log :debug, "transaction is registered"
      @queue.push f
    end

    def add(kind, x)
      @db[kind] << x
      call_listener(kind, x)
    end

    def set(kind, xs)
      @db[kind] = xs
      call_listener(kind, xs)
    end

    private
    def call_listener(kind, s)
      @listeners[kind].each do|f|
        f.call s
      end
    end
  end
end

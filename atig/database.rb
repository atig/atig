#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/sized_array'
require 'thread'

module Atig
  class Database
    include Util

    class Statuses
      def initialize(size)
        @db = SizedArray.new(size)
        @listeners = []
      end

      def add(src, status)
        unless @db.include? status.id then
          @db << status
          call_listener src, status
        end
      end

      def listen(&f)
        @listeners << f
      end

      def tid(id)
        @db[id]
      end

      private
      def call_listener(src,status)
        @listeners.each do| f |
          f.call src, status
        end
      end
    end

    class Followeres; end

    attr_reader :status, :follower

    def initialize(logger, size)
      @log = logger
      log :info, "initialize"

      @queue = SizedQueue.new 10
      daemon do
        f = @queue.pop
        log :debug, "transaction is poped"

        f.call self

        log :debug, "transaction is finished"
      end

      @status   = Statuses.new size
      @follower = Followeres.new
    end

    def transaction(&f)
      log :debug, "transaction is registered"
      @queue.push f
    end
  end
end

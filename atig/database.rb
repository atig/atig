#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/sized_array'
require 'thread'
require 'set'
require 'forwardable'
require 'time'

module Atig
  class Database
    include Util

    class Statuses
      attr_reader :me

      def initialize(me, size)
        @me = me
        @db = SizedArray.new(size)
        @listeners = []
      end

      def add(src, status)
        unless @db.include? status.id then
          @db << status

          if is_me? status then
            call_listener :me, status

            user = status.user
            user[:status] = status
            @me = status.user
          else
            call_listener src,status
          end
        end
      end

      def listen(&f)
        @listeners << f
      end

      def tid(id)
        @db[id]
      end

      private
      def is_me?(status)
        return false unless status.user.id == @me.id

        begin
          Time.parse(status.created_at) >= Time.parse(@me.status.created_at)
        rescue
          true
        end
      end

      def call_listener(src,status)
        @listeners.each do| f |
          f.call src, status
        end
      end
    end

    class Friends
      extend Forwardable
      def_delegators(:@xs, :size, :empty?,:[])

      def initialize
        @xs = []
        @listeners = []
      end

      def update(xs)
        diff(xs, @xs).each do|friend|
          call_listener :come, friend
        end

        diff(@xs, xs).each do|friend|
          call_listener :bye, friend
        end

        @xs = xs
      end

      def listen(&f)
        @listeners << f
      end

      private
      def call_listener(kind, friend)
        @listeners.each do| f |
          f.call kind, friend
        end
      end

      def diff(xs, ys)
        xs.select{|x| not ys.any?{|y| x.id == y.id } }
      end
    end

    attr_reader :status, :friends

    def initialize(logger, opt)
      @log = logger
      log :info, "initialize"

      @queue = SizedQueue.new 10
      daemon do
        f = @queue.pop
        log :debug, "transaction is poped"

        f.call self

        log :debug, "transaction is finished"
      end

      @status   = Statuses.new opt[:me], opt[:size]
      @friends  = Friends.new
    end

    def transaction(&f)
      log :debug, "transaction is registered"
      @queue.push f
    end
  end
end

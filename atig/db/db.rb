#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'
require 'atig/db/statuses'
require 'atig/util'
require 'thread'
require 'set'

module Atig
  module Db
    class Db
      include Util
      attr_reader :followings, :statuses, :me

      def initialize(logger, opt={})
        @followings = Followings.new
        @statuses   = Statuses.new(opt[:size] || 1000)
        @me         = opt[:me]
        @log     = logger

        log :info, "initialize"

        @queue = SizedQueue.new 10
        daemon do
          f = @queue.pop
          log :debug, "transaction is poped"

          f.call self

          log :debug, "transaction is finished"
        end
      end

      def transaction(&f)
        log :debug, "transaction is registered"
        @queue.push f
      end
    end
  end
end

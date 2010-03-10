#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  class Scheduler
    include Util

    def initialize(log, api)
      @log = log
      @api = api
      @agents = []

      @queue = SizedQueue.new 10
      daemon do
        f = @queue.pop
        f.call
      end
    end

    def repeat(interval,opts={}, &f)
      t = daemon do
        log :debug, "agent #{t.inspect} is invoked"
        @queue.push(lambda{ safe { f.call @api } })
        sleep interval
      end

      log :info, "repeat agent #{t.inspect} is registered"
      @agents << t
      t
    end

    def delay(interval, opts={}, &f)
      sleep interval
      f.call @api
    end

    def re_try(count, &f)
      begin
        f.call
      rescue => e
        log :error, [count, e.inspect].inspect
        if count > 0
          count -= 1
          sleep 1
          log :debug, "retry"
          retry
        end
        log :error, "Some Error Happened: #{e}"
        raise e
      end
    end
  end
end

# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  class Scheduler
    include Util

    attr_reader :search

    def initialize(context, api, search, stream)
      @log    = context.log
      @api    = api
      @search = search
      @stream = stream
      @agents = []

      @queue = SizedQueue.new 10
      daemon do
        f = @queue.pop
        f.call
      end
    end

    def repeat(interval,opts={}, &f)
      @queue.push(lambda{ safe { f.call @api } })
      t = daemon do
        sleep interval
        log :debug, "agent #{t.inspect} is invoked"
        @queue.push(lambda{ safe { f.call @api } })
      end

      log :info, "repeat agent #{t.inspect} is registered"
      @agents << t
      t
    end

    def delay(interval, opts={}, &f)
      sleep interval
      @queue.push(lambda{ safe { f.call @api } })
    end

    def stream(&f)
      return nil unless @stream
      @stream_thread.kill if @stream_thread
      @stream_thread = daemon {
        f.call @stream
      }
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

    def limit
      @api.limit
    end

    def remain
      @api.remain
    end

    def reset
      @api.reset
    end
  end
end

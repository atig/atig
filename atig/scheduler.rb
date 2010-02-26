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
    end

    def repeat(interval,&f)
      t = daemon do
        log :debug, "agent #{t.inspect} is invoked"
        f.call @api
        sleep interval
      end

      log :info, "repeat agent #{t.inspect} is registered"
      @agents << t
      t
    end
  end
end

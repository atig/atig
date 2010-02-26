#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  class Scheduler
    def initialize(log, api)
      @log = log
      @api = api
      @id  = 0
    end

    def repeat(interval,&f)
      @id += 1

      log :info, "repeat #{@id}"
      Thread.new do
        begin
          log :debug, "#{@id} handler is invoked"
          safe { f.call @api }
          sleep interval
        rescue => e
          @log.error e.inspect
        end
      end
      @id
    end

    private
    def log(:type, s)
      @log.send "[#{self.class}] s"
    end

    def safe(&f)
      begin
        f.call
      rescue Exception => e
        s = e.inspect + "\n"
        e.backtrace.each do |l|
          s += "\t#{l}\n"
        end

        @log.error s
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Util
    private
    def log(type, s)
      if @log then
        @log.send type, "[#{self.class}] #{s}"
      else
        STDERR.puts s
      end
    end

    def safe(&f)
      begin
        f.call
      rescue Exception => e
        s = e.inspect + "\n"
        e.backtrace.each do |l|
          s += "\t#{l}\n"
        end

        log :error,s
      end
    end

    def daemon(&f)
      Thread.new do
        safe do
          loop(&f)
        end
      end
    end
  end
end

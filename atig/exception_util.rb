#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module ExceptionUtil
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
        loop{ safe { f.call }}
      end
    end

    module_function :safe,:daemon
  end
end

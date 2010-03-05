#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/exception_util'
module Atig
  module Util
    private
    include ExceptionUtil
    def log(type, s)
      if @log then
        @log.send type, "[#{self.class}] #{s}"
      else
        STDERR.puts s
      end
    end
  end
end

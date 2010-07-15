#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'timeout'
require 'atig/util'

module Atig
  module Db
    module Transaction
      include Util

      def init
        return if @queue

        debug "transaction thread start"
        @queue = SizedQueue.new 10
        daemon do
          f,src = @queue.pop
          debug "transaction is poped at #{src}"

          if respond_to?(:timeout_interval) && timeout_interval > 0 then
            begin
              timeout(timeout_interval){ f.call self }
            rescue TimeoutError
              debug "transaction is timeout at #{src}"
            end
          else
            f.call self
          end

          debug "transaction is finished at #{src}"
        end
      end

      def transaction(&f)
        init

        debug "transaction is registered"
        @queue.push [ f, caller.first ]
      end

      def debug(s)
        if respond_to? :log
          log :debug, s
        end
      end
    end
  end
end

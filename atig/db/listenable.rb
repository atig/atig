#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'forwardable'

module Atig
  module Db
    module Listenable
      SingleThread = false
      def listen(&f)
        @listeners ||= []
        @listeners.push f
      end

      private
      def notify(*args)
        @listeners ||= []
        if SingleThread then
          @listeners.each{|f|
            f.call(*args)
          }
        else
          Thread.start {
            @listeners.each{|f|
              f.call(*args)
            }
          }
        end
      end
    end
  end
end

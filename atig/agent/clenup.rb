#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Cleanup
      include Util

      def initialize(context, api, db)
        daemon do
          db.transaction do|t|
            t.cleanup
          end
          sleep 60*60
        end
      end
    end
  end
end

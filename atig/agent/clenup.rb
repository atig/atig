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
          # once a day
          sleep 60*60*24
        end
      end
    end
  end
end

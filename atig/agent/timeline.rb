#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Timeline
      include Util

      def initialize(logger, api, db)
        @log = logger
        log :info, "initialize"

        @api = api
        @api.repeat(5) do|t|
          t.get('/status/home_timeline').each do|status|
            db.add :status, status
          end
        end
      end
    end
  end
end

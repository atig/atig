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
        @api.repeat(30) do|t|
          statuses = t.get('/statuses/home_timeline')

          db.transaction do|t|
            statuses.reverse_each do|status|
              t.add :status,status
            end
          end
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Timeline
      include Util

      def initialize(logger, api, db)
        @log = logger
        @prev = nil
        @first = true
        log :info, "initialize"

        @api = api
        @api.repeat(30) do|t|
          q = { :count => 200 }
          q.update(:since_id => @prev) if @prev
          q.update(:count => 20) if @first
          @first = false

          statuses = t.get('/statuses/home_timeline', q)

          db.transaction do|t|
            statuses.reverse_each do|status|
              t.status.add :timeline, status
            end
          end
          @prev = statuses[0].id if statuses && statuses.size > 0
        end
      end
    end
  end
end

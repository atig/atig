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
        log :info, "initialize"

        @api = api
        @api.repeat(30) do|t|
          q = { :count => 200 }

          if @prev
            q.update :since_id => @prev
          else
            q.update :count => 20
          end

          statuses = t.get('/statuses/home_timeline', q)

          db.transaction do|d|
            statuses.reverse_each do|status|
              d.status.add :timeline, status
            end
          end
          @prev = statuses[0].id if statuses && statuses.size > 0
        end
      end
    end
  end
end

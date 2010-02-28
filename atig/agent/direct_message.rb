#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class DirectMessage
      include Util

      def initialize(logger, api, db)
        @log = logger
        @api = api
        @prev = nil

        log :info, "initialize"

        @api.repeat(600) do|t|
          q = { :count => 200 }
          if @prev
            q.update :since_id => @prev
          else
            q.update :count => 1
          end
          dms = t.get("direct_messages", q)
          log :debug, "You have #{dms.size} dm."

          db.transaction do|d|
            dms.reverse_each do|dm|
              d.direct_messages.add dm
            end
          end
        end
      end
    end
  end
end

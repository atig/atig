#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Mention
      include Util

      def initialize(logger, api, db)
        @log = logger
        @api = api
        @prev = nil

        log :info, "initialize"

        @api.repeat(180) do|t|
          q = { :count => 200 }
          if @prev
            q.update :since_id => @prev
          else
            q.update :count => 20
          end

          mentions = t.get("statuses/mentions", q)

          db.transaction do|t|
            mentions.reverse_each do|mention|
              db.status.add :mention, mention
            end
          end
          @prev = mentions[0].id if mentions && mentions.size > 0
        end
      end
    end
  end
end

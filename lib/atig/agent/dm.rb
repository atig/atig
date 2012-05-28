# -*- mode:ruby; coding:utf-8 -*-
require 'atig/util'

module Atig
  module Agent
    class Dm
      include Util

      def initialize(context, api, db)
        return if context.opts.stream
        @log = context.log
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

          dms.reverse_each do|dm|
            db.dms.transaction do|d|
              d.add :status => dm, :user => dm.sender
            end
          end
        end
      end
    end
  end
end

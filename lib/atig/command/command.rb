# -*- mode:ruby; coding:utf-8 -*-
module Atig
  module Command
    class Command
      attr_reader :gateway, :api, :db, :opts
      def initialize(context, gateway, api, db)
        @log     = context.log
        @opts    = context.opts
        @gateway = gateway
        @api     = api
        @db      = db
        @gateway.ctcp_action(*command_name) do |target, mesg, command, args|
          action(target, mesg, command, args){|m|
            gateway[target].notify m
          }
        end
      end

      def find_by_tid(tid)
        @db.statuses.find_by_tid tid
      end
    end
  end
end

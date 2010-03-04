#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
module Atig
  module Command
    class SingleAction
      def initialize(gateway,actions)
        @gateway = gateway
	@gateway.ctcp_action(*actions) do |target, mesg, command, args|
          action target, mesg, command , args
	end
      end

      protected
      def action
        raise "must override sub class"
      end

      def notify(s)
        @gateway.log :info,s
      end

      def gateway; @gateway end

      def find_by_tid(id)
        @gateway.db.statuses.find_by_tid id
      end
    end
  end
end

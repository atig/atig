#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module  Command
    class Footer
      def initialize(logger, gateway)
	gateway.ctcp_action "hello" do |target, mesg, command, args|
          gateway.log :info, "hello,world"
	end
      end
    end
  end
end

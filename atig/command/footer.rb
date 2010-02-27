#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Command
    class Footer
      def initialize(logger, gateway)
        @footer = ""
	gateway.ctcp_action "footer" do |target, mesg, command, args|
          @footer = args.join ' '
          gateway.log :info, "footer becomes '#{@footer}'"
	end

        gateway.ofilters << lambda{|q|
          q.merge :status => "#{q[:status]} #{@footer}"
        }
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/single_action'

module Atig
  module Command
    class Uptime < SingleAction
      def initialize(gateway)
        super(gateway,%w(uptime))
        @time = Time.now
      end

      def action(target,mesg, command,args)
        gateway.notify target, format(Time.now - @time)
      end

      def format(x)
        day , y   = x.divmod(60*60*24)
        hour, z   = y.divmod(60*60)
        min , sec = z.divmod(60)

        s = ""
        s += "#{day} days" if day > 0
        s += "%02d" % hour if hour > 0
        s += "%02d:%02d" % [min,sec]
        s
      end
    end
  end
end

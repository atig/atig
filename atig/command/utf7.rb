#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Command
    class Utf7
      def initialize(gateway)
        @utf7 = false
	gateway.ctcp_action "utf-7", "utf7" do |target, mesg, command, args|
          unless defined? ::Iconv
            log "Can't load iconv."
            return
          end
          @utf7 = !@utf7
          gateway.log :info,"UTF-7 mode: #{@utf7 ? 'on' : 'off'}"
	end

        gateway.ofilters << lambda{|q|
          return q unless @utf7

          m = Iconv.iconv("UTF-7", "UTF-8", q[:status]).join.encoding!("ASCII-8BIT")
          q.merge :status => m
        }
      end
    end
  end
end

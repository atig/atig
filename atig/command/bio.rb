#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/exception_util'
require 'atig/command/single_action'

module Atig
  module Command
    class Bio < SingleAction
      include ExceptionUtil
      def initialize(gateway)
        super(gateway,%w(bio))
      end

      def action(target,mesg, command,args)
        if args.empty?
          notify "/me #{command} <ID>"
          return
        end
        nick = args.first

        gateway.api.delay(0) do|t|
          user = t.get("users/show", { :screen_name => nick})
          status = user.status.merge(:text => user.description)
          gateway.message(TwitterStruct.make({
                                               'status' => status,
                                               'user' => user
                                             }),
                          target,
                          Net::IRC::Constants::NOTICE)
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/exception_util'
require 'atig/command/single_action'

module Atig
  module Command
    class Reply < SingleAction
      include ExceptionUtil
      def initialize(gateway)
        super(gateway,%w(mention re reply))
      end

      def action(target,mesg, command,args)
        if args.empty?
          notify "/me #{command} <ID> blah blah"
          return
        end

        tid = args.first
        if status = find_by_tid(tid) then
          text = mesg.split(" ", 3)[2]
          name = status.user.screen_name

          text = "@#{name} #{text}" if text.nil? or not text.include?(name)

          q = gateway.output_message(:status => text,
                                     :source => gateway.api_source,
                                     :in_reply_to_status_id => status.id)

          gateway.api.delay(0) do|t|
            ret = t.post("statuses/update", q)
            safe {
              msg = gateway.input_message(status)
              gateway.update_my_status ret,target, "In reply to #{tid}: #{msg}"
            }
          end
        end
      end
    end
  end
end

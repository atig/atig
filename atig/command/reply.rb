#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Command
    class Reply
      def initialize(gateway)
	gateway.ctcp_action "mention","re","reply" do |target, mesg, command, args|
          # reply, re, mention
          tid = args.first
          if status = gateway.db.status.tid(tid) then
            text = mesg.split(" ", 3)[2]
            name = status.user.screen_name

            text = "@#{name} #{text}" if text.nil? or not text.include?(name)

            q = gateway.output_message(:status => text,
                                       :source => gateway.api_source,
                                       :in_reply_to_status_id => status.id)

            gateway.api.delay(0) do|t|
              ret = t.post("statuses/update", q)
              gateway.update_my_status ret

              msg = gateway.input_message(status)
              url = gateway.permalink(status)
              gateway.log :info, "Status updated (In reply to #{tid}: #{msg} <#{url}>)"
            end
          end
	end
      end
    end
  end
end

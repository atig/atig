#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/command/single_action'
require 'jcode'

module Atig
  module Command
    class Retweet < SingleAction
      include Util

      def initialize(gateway)
        super(gateway,%w(ort rt retweet qt))
      end

      def rt_with_comment(comment, entry)
        screen_name = "@#{entry.user.screen_name}"
        text = "#{comment} RT #{screen_name}: #{entry.status.text}"

        chars = text.each_char
        if chars.size > 140 then
          url = gateway.output_message(:status =>
                                       "http://twitter.com/#{entry.user.screen_name}/status/#{entry.status.id}")[:status]
          text = chars[0,140-url.size].join('') + url
        end
        q = gateway.output_message(:status => text,
                                   :source => gateway.api_source)
        gateway.api.delay(0) do|t|
          ret = t.post("statuses/update", q)
          safe {
            gateway.update_my_status ret
            notify "Status updated (RT to #{entry.tid}: #{text})"
          }
        end
      end

      def rt_with_no_comment(entry)
        gateway.api.delay(0) do|t|
          ret = t.post("statuses/retweet/#{entry.status.id}",{ :source => gateway.api_source })

          safe {
            gateway.update_my_status ret
            notify "Status updated (RT to #{entry.tid}: #{entry.status.text})"
          }
        end
      end

      def action(target,mesg, command,args)
        if args.empty?
          notify "/me #{command} <ID> blah blah"
          return
        end

        tid = args.first
        if status = find_by_tid(tid) then
          if args.size >= 2
            comment = mesg.split(" ", 3)[2] + " "
            rt_with_comment(comment, status)
          else
            rt_with_no_comment(status)
          end
        end
      end
  end
  end
end

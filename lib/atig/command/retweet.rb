# -*- mode:ruby; coding:utf-8 -*-

require 'atig/bitly'
require 'atig/command/command'
begin
  require 'jcode'
rescue LoadError
end

module Atig
  module Command
    class Retweet < Atig::Command::Command
      def initialize(*args)
        super
        @bitly = Bitly.no_login @log
      end

      def command_name; %w(ort rt retweet qt) end

      def rt_with_comment(target, comment, entry)
        screen_name = "@#{entry.user.screen_name}"
        text = "#{comment.strip} RT #{screen_name}: #{entry.status.text}"

        chars = text.each_char.to_a
        chars_length = text.encode("UTF-16BE", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
        if chars_length.each_char.to_a.size > 140 then
          url = @bitly.shorten "http://twitter.com/#{entry.user.screen_name}/status/#{entry.status.id}"
          text = chars[0,140-url.size-1].join('') + ' ' + url
        end
        q = gateway.output_message(:status => text)
        api.delay(0) do|t|
          ret = t.post("statuses/update", q)
          gateway.update_status ret,target, "RT to #{entry.user.screen_name}: #{entry.status.text}"
        end
      end

      def rt_with_no_comment(target, entry)
        api.delay(0) do|t|
          ret = t.post("statuses/retweet/#{entry.status.id}")
          gateway.update_status ret,target, "RT to #{entry.user.screen_name}: #{entry.status.text}"
        end
      end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} <ID_or_SCREEN_NAME> blah blah"
          return
        end

        tid = args.first
        if status = Info.find_status(db, tid) then
          if args.size >= 2
            comment = mesg.split(" ", 3)[2] + " "
            rt_with_comment(target, comment, status)
          else
            rt_with_no_comment(target, status)
          end
        else
          yield "No such ID : #{tid}"
        end
      end
    end
  end
end

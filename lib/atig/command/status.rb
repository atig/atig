# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'twitter-text'

module Atig
  module Command
    class Status < Atig::Command::Command
      include ::Twitter::TwitterText::Validation

      def command_name; %w(status) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} blah blah"
          return
        end
        text = mesg.split(" ", 2)[1]
        previous,*_ = db.statuses.find_by_user( db.me, limit: 1)
        if previous and
            ((::Time.now - ::Time.parse(previous.status.created_at)).to_i < 60*60*24 rescue true) and
            text.strip == previous.status.text.strip
          yield "You can't submit the same status twice in a row."
          return
        end
        q = gateway.output_message(status: text)

        case tweet_invalid? q[:status]
        when :too_long
          yield "You can't submit the status over 140 chars"
          return
        when :invalid_characters
          yield "You can't submit the status invalid chars"
          return
        end

        api.delay(0, retry:3) do|t|
          ret = t.post("statuses/update", q)
          gateway.update_status ret,target
        end
        
      end
    end
  end
end

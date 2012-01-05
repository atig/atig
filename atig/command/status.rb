# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
begin
  require 'jcode'
rescue LoadError
end

module Atig
  module Command
    class Status < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(status) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} blah blah"
          return
        end
        text = mesg.split(" ", 2)[1]
        previous,*_ = db.statuses.find_by_user( db.me, :limit => 1)
        if previous and
            ((::Time.now - ::Time.parse(previous.status.created_at)).to_i < 60*60*24 rescue true) and
            text.strip == previous.status.text.strip
          yield "You can't submit the same status twice in a row."
          return
        end
        q = gateway.output_message(:status => text)

        if q[:status].each_char.to_a.size > 140 then
          yield "You can't submit the status over 140 chars"
          return
        end

        api.delay(0, :retry=>3) do|t|
          ret = t.post("statuses/update", q)
          gateway.update_status ret,target
        end
      end
    end
  end
end

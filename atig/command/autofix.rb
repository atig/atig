# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/levenshtein'

begin
  require 'jcode'
rescue LoadError
end

module Atig
  module Command
    class Autofix < Atig::Command::Command
      def initialize(*args); super end
      def command_name; /(?:autofix|topic|overwwrite)!?/ end

      def distance(s1, s2)
        c1 = s1.split(//)
        c2 = s2.split(//)
        distance = Atig::Levenshtein.levenshtein c1, c2
        distance.to_f / [ c1.size, c2.size ].max
      end

      def fix?(command, text, prev)
        command[-1,1] == '!' or distance(text, prev.status.text) < 0.5
      end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} blah blah"
          return
        end
        text = mesg.split(" ", 2)[1]
        q = gateway.output_message(:status => text)

        prev,*_ = db.statuses.find_by_user( db.me, :limit => 1)

        unless fix?(command, q[:status], prev) then
          api.delay(0, :retry=>3) do|t|
            ret = t.post("statuses/update", q)
            gateway.update_status ret, target
          end
        else
          api.delay(0, :retry=>3) do|t|
            yield "Similar update in previous. Conclude that it has error."
            yield "And overwrite previous as new status: #{q[:status]}"

            ret = t.post("statuses/update", q)
            gateway.update_status ret, target
            t.post("statuses/destroy/#{prev.status.id}")
            db.statuses.transaction{|d|
              d.remove_by_id prev.id
            }
          end
        end
      end
    end
  end
end

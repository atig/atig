# -*- mode:ruby; coding:utf-8 -*-

# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/info'
require 'time'
module Atig
  module Command
    class Refresh < Atig::Command::Command
      def command_name; %w(refresh) end

      def action(target, mesg, command,args)
        db.followings.invalidate
        db.lists.invalidate :all
        yield "refresh followings/lists..."
      end
    end
  end
end

# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Dm
      def initialize(context, gateway, db)
        channel = gateway.channel db.me.screen_name
        db.dms.listen do|dm|
          channel.message(dm)
        end
      end
    end
  end
end

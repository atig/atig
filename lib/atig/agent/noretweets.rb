# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Noretweets
      include Util

      def initialize(context, api, db)
        @opts = context.opts
        @log  = context.log
        @db   = db
        log :info, "initialize"

        api.repeat(3600){|t| update t }
      end

      def update(api)
        @db.noretweets.clear.concat( api.get("friendships/no_retweet_ids") )
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Friend
      include Util

      def initialize(logger, api, db)
        @log = logger
        log :info, "initialize"

        api.repeat(3600) do|t|
          @me = t.post("account/update_profile")

          if db.friends.empty? or @me.friends_count != db.friends.size
            friends = t.page("statuses/friends/#{@me.id}", :users)
            log :info, "You have #{friends.size} friends"

            db.friends.update friends
          end
        end
      end
    end
  end
end

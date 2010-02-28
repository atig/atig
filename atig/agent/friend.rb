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
          if db.friends.empty? or db.me.friends_count != db.friends.size
            friends = t.page("statuses/friends/#{db.me.id}", :users)
            log :info, "You have #{friends.size} friends"

            db.transaction do|d|
              d.friends.update friends
            end
          end
        end
      end
    end
  end
end

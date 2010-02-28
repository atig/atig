#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Follower
      include Util

      def initialize(logger, api, db)
        @log = logger
        log :info, "initialize"

        api.repeat(3600) do|t|
          log :info, "follower agent is invoked"
          followers = t.page("followers/ids/#{db.me.id}", :ids)
          log :info, "You have #{followers.size} followers"
          db.transaction do|d|
            d.followers.update followers
          end
        end
      end
    end
  end
end

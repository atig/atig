#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Following
      include Util

      def initialize(context, api, db)
        @log = context.log
        @db  = db
        log :info, "initialize"

        api.repeat(3600) do|t|
          if @db.followings.empty?
            friends = t.page("statuses/friends/#{@db.me.id}", :users)
          else
            @db.me = t.post("account/update_profile")
            return if @db.me.friends_count == @db.followings.size
            friends = t.get("statuses/friends/#{@db.me.id}", :users)
          end

          if context.opts.only
            followers = t.page("followers/ids/#{@db.me.id}", :ids)
            friends.each do|friend|
              friend[:only] = !followers.include?(friend.id)
            end
          end

          @db.transaction{|d|
            d.followings.update friends
          }
        end
      end
    end
  end
end

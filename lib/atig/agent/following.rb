# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Following
      include Util

      def initialize(context, api, db)
        @opts = context.opts
        @log  = context.log
        @db  = db
        log :info, "initialize"

        api.repeat(3600){|t| update t }
        @db.followings.on_invalidated{
          log :info, "invalidated followings"
          api.delay(0){|t| update t }
        }
      end

      def update(api)
        if @db.followings.empty?
          friends = api.page("friends/list", :users, {:user_id => @db.me.id})
        else
          @db.me = api.post("account/update_profile")
          return if @db.me.friends_count == @db.followings.size
          friends = api.page("friends/list", :users, {:user_id => @db.me.id})
        end

        if @opts.only
          followers = api.page("friends/ids", :ids, {:user_id => @db.me.id})
          friends.each do|friend|
            friend[:only] = !followers.include?(friend.id)
          end
        end

        @db.followings.transaction do|d|
          d.update friends
        end
      end
    end
  end
end

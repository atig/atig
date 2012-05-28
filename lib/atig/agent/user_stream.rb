# -*- mode:ruby; coding:utf-8 -*-
require 'atig/util'

module Atig
  module Agent
    class UserStream
      include Util

      def initialize(context, api, db)
        @log = context.log
        @api = api
        @prev = nil

        return unless context.opts.stream

        log :info, "initialize"

        @api.stream do|t|
          t.watch('user') do |status|
#            @log.debug status.inspect
            if status and status.user
              db.statuses.transaction do|d|
                d.add :status => status, :user => status.user, :source => :user_stream
              end
            end
            if status and status.event
              case status.event
              when 'list_member_added'
                t.channel.notify "list member \00311added\017 : @#{status.target.screen_name} into #{status.target_object.full_name} [ http://twitter.com#{status.target_object.uri} ]"
              when 'list_member_removed'
                t.channel.notify "list member \00305removed\017 : @#{status.target.screen_name} from #{status.target_object.full_name} [ http://twitter.com#{status.target_object.uri} ]"
              when 'follow'
                t.channel.notify "#{status.source.screen_name} \00311follows\017 @#{status.target.screen_name}"
              when 'favorite'
                t.channel.notify "#{status.source.screen_name} \00311favorites\017 => @#{status.target_object.user.screen_name} : #{status.target_object.text}"
               when 'unfavorite'
                t.channel.notify "#{status.source.screen_name} \00305unfavorites\017 => @#{status.target_object.user.screen_name} : #{status.target_object.text}"
              end
            end
          end
        end
      end
    end
  end
end

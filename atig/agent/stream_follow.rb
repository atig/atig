#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/util'

module Atig
  module Agent
    class StreamFollow
      include Util

      def initialize(context, api, db)
        @log = context.log
        @api = api
        @prev = nil

        log :info, "initialize"

        @api.delay(0)do|t|
          @follows = context.opts.follow.split(',').map{|user|
            t.get("users/show",:screen_name=>user).id
          }.join(',')
        end


        @api.stream do|t|
          Thread.pass until @follows
          t.watch('statuses/filter', :follow => @follows) do |status|
            db.transaction do|d|
              d.statuses.add :status => status, :user => status.user, :source => :timeline
            end
          end
        end
      end
    end
  end
end

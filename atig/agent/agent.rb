#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Agent
      include Util

      def initialize(context, api, db)
        @log = context.log
        @api = api
        @prev = nil

        log :info, "initialize"

        @api.repeat( interval ) do|t|
          q = { :count => 200 }
          if @prev
            q.update :since_id => @prev
          else
            q.update :count => 20
          end

          sources = t.get( path, q)

          db.transaction do|t|
            sources.reverse_each do|s|
              db.statuses.add :source => source, :status => s, :user => s.user
            end
          end
          @prev = sources.first.id if sources && !sources.empty?
        end
      end
    end
  end
end

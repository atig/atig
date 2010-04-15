#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/util'

module Atig; end
module Atig::Agent; end

class Atig::Agent::Query
  include Atig::Util

  def initialize(context, api, db)
    @log = context.log
    @db  = db
    log :info, "initialize"

    @prev = {}
    api.repeat(60, :api=>:search) do|t|
      db.searches.each do |search|
        log :debug, "query: #{search.query}"
        q = { :q => search.query }
        q.update(:since_id => @prev[search.name]) if @prev.key?(search.name)
        statuses = t.api("search", q).results
        db.transaction do|d|
          statuses.reverse_each do|status|
            d.statuses.add(:status => status,
                           :user   => OpenStruct.new(:screen_name => status.from_user,
                                                     :id          => status.from_user_id),
                           :source => :search,
                           :name   => search.name)
          end
        end
        @prev[search.name] = statuses[0].id if statuses && statuses.size > 0
      end
    end
  end
end


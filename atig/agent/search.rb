#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  module Agent
    class Search
      include Util

      def initialize(context, api, db)
        @log = context.log
        @db  = db
        log :info, "initialize"

        api.repeat(3600) do|t|
          searches = t.get "saved_searches"
          @db.searches.update searches
        end
      end
    end
  end
end

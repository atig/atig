#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Agent
    class Timeline
      def initialize(logger, api, db)
        logger.info "initialize #{self.class}"
        @api = api

        @api.repeat(5) do|t|
          logger.debug "start #{self.class}"

          t.get('/status/home_timeline').each do|status|
            db.add :status, status
          end
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  class Gateway
    def initialize(logger, api, db)
      logger.info "initialize #{self.class}"

      db.listen(:status) do|s|
        puts s
      end

      db.listen(:member) do|s|
        puts s
      end

      loop do
        sleep 10
      end
    end
  end
end

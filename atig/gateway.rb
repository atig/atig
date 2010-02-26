#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'

module Atig
  class Gateway
    include Util

    def initialize(logger, api, db)
      @log = logger
      log :info, "initialize"

      db.listen(:status) do|s|
        log :info, s
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

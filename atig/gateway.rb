#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  class Gateway
    def initialize(api, db)
      db.listen(:status) do|s|
        puts s
      end

      db.listen(:member) do|s|
        puts s
      end
    end
  end
end

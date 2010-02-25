#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  class Timeline
    def initialize(scheduler, db)
      @scheduler = scheduler

      @scheduler.repeat(30) do|t|
        t.get('/status/home_timeline').each do|status|
          db.add :status, status
        end
      end
    end
  end
end

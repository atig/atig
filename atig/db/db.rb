#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'
require 'atig/db/statuses'

module Atig
  module Db
    class Db
      attr_reader :followings, :statuses

      def initialize(opt={})
        @followings = Followings.new
        @statuses   = Statuses.new(opt[:size] || 1000)
      end
    end
  end
end

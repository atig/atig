# -*- mode:ruby; coding:utf-8 -*-
require 'atig/agent/agent'

module Atig
  module Agent
    class Timeline < Atig::Agent::Agent
      DEFAULT_INTERVAL = 60

      def initialize(context, api, db)
        @opts = context.opts
        return if @opts.stream
        super
      end

      def interval
        @interval ||= @opts.interval.nil? ? DEFAULT_INTERVAL : @opts.interval.to_i
      end

      def path; '/statuses/home_timeline' end
      def source; :timeline end
    end
  end
end

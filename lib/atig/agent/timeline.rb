# -*- mode:ruby; coding:utf-8 -*-
require 'atig/agent/agent'

module Atig
  module Agent
    class Timeline < Atig::Agent::Agent
      def initialize(context, api, db); super end
      def interval; 30 end
      def path; '/statuses/home_timeline' end
      def source; :timeline end
    end
  end
end

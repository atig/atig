# -*- mode:ruby; coding:utf-8 -*-
require 'atig/agent/agent'

module Atig
  module Agent
    class Mention < Atig::Agent::Agent
      def initialize(context, api, db); super end
      def interval; 180 end
      def path; '/statuses/mentions' end
      def source; :mention end
    end
  end
end

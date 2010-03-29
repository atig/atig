#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/agent/agent'

module Atig
  module Agent
    class RetweetedToMe < Atig::Agent::Agent
      def initialize(context, api, db); super end
      def interval; 180 end
      def path; '/statuses/retweeted_to_me' end
      def source; :retweeted_to_me end
    end
  end
end

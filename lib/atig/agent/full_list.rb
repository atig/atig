# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/agent/list'

module Atig
  module Agent
    class FullList < List
      def entry_points
        [
          "lists/list",
        ]
      end

      def interval
        3600
      end
    end
  end
end

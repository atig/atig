# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require 'atig/agent/list'

module Atig
  module Agent
    class OwnList < List
      def entry_points
        [ "#{@db.me.screen_name}/lists" ]
      end

      def interval
        3600
      end
    end
  end
end

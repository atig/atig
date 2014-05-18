# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    module RetweetTime
      def self.call(status)
        unless status.retweeted_status then
          status
        else
          t = Time.gm(*Time.parse(status.retweeted_status.created_at).to_a)
          status.merge text: "#{status.text} \x0310[#{t.strftime "%Y-%m-%d %H:%M"}]\x0F"
        end
      end
    end
  end
end

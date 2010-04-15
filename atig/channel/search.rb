#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Search
      def initialize(context, gateway, db)
        @gateway  = gateway
        @channels = Hash.new do|hash,name|
          channel = gateway.channel "#s:#{name}"
          channel.join_me
          hash[name] = channel
        end

        db.searches.listen do|kind, s|
          @channels[s.name].send kind, []
        end

        db.statuses.listen do|entry|
          if entry.source == :search then
            @channels[entry.name].message entry
          end
        end
      end
    end
  end
end

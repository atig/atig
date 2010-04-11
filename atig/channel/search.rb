#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Search
      def initialize(context, gateway, db)
        @gateway  = gateway
        @channels = {}

        db.searches.listen do|kind, s|
          unless @channels.key? s.name then
            @channels[s.name] = make s.name, s.query
          end
          @channels[s.name][:channel].send kind, []
        end

        db.statuses.listen do|entry|
          if entry.source == :search then
            @channels[entry.search_name].message entry
          else
            @channels.each do|_, ch|
              if entry.status.text.include?(ch[:query]) then
                ch[:channel].message entry
              end
            end
          end
        end
      end

      private
      def make(name, query)
        channel = @gateway.channel "#s:#{name}"
        channel.join_me
        {
          :channel => channel,
          :query   => query,
        }
      end
    end
  end
end

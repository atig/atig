#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Channel
    class Search
      class Handler
        def initialize(db, name)
          @db   = db
          @name = name
        end
      end

      def initialize(context, gateway, db)
        @channels = Hash.new do|hash,name|
          channel = gateway.channel "#s:#{name}", :handler => Handler.new(db, name)
          channel.join_me
          hash[name] = channel
        end

        db.searches.listen do|kind, s|
          @channels[s.name].send kind,[]
        end
      end
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module OFilter
    class Geo
      def initialize(context)
        @opts = context.opts
      end

      def call(q)
        return q unless @opts.ll
        lat, long = @opts.ll.split(",", 2)
        q.merge :lat  => lat.to_f, :long => long.to_f
      end
    end
  end
end

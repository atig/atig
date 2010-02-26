#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module IFilter
    class Strip
      def initialize(suffix=[])
        @rsuffix = /#{Regexp.union(*suffix)}\z/
      end

      def call(s, _)
        s.sub(@rsuffix, "").strip
      end
    end
  end
end

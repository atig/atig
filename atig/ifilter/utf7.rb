#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require "iconv"

module Atig
  module IFilter
    class DecodeUtf7
      include Util
      def initialize(log, *_)
        @log = log
      end

      def call(str, _)
        return str unless defined? ::Iconv and str.include?("+")

        str.sub(/\A(?:.+ > |.+\z)/) { Iconv.iconv("UTF-8", "UTF-7", $&).join }
      rescue Iconv::IllegalSequence
        str
      rescue => e
        log :error,e
        str
      end
    end
  end
end

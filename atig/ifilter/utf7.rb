#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require "iconv"

module Atig
  module IFilter
    class Utf7
      include Util
      def initialize(context)
        @log = context.log
      end

      def call(status)
        return status unless defined? ::Iconv and status.text.include?("+")

        status.merge :text => status.text.sub(/\A(?:.+ > |.+\z)/) { Iconv.iconv("UTF-8", "UTF-7", $&).join }
      rescue Iconv::IllegalSequence
        status
      rescue => e
        log :error,e
        status
      end
    end
  end
end

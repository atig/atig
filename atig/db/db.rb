#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'
require 'atig/db/statuses'
require 'atig/db/lists'
require 'atig/util'
require 'thread'
require 'set'
require 'fileutils'
require 'tmpdir'

module Atig
  module Db
    class Db
      include Util
      attr_reader :followings, :statuses, :dms, :lists
      attr_accessor :me
      Path = ::Dir.tmpdir
      VERSION = 4

      def initialize(context, opt={})
        @log        = context.log
        @me         = opt[:me]

        @followings = Followings.new dir('following')
        @statuses   = Statuses.new   dir('status')
        @dms        = Statuses.new   dir('dm')
        @lists      = Lists.new      dir('lists.%s')

        log :info, "initialize"

        @queue = SizedQueue.new 10
        daemon do
          f = @queue.pop
          log :debug, "transaction is poped"

          f.call self

          log :debug, "transaction is finished"
        end
      end

      def dir(id)
        dir = File.expand_path "atig/#{@me.screen_name}/", Path
        log :debug, "db(#{id}) = #{dir}"
        FileUtils.mkdir_p dir
        File.expand_path "#{id}.#{VERSION}.db", dir
      end

      def transaction(&f)
        log :debug, "transaction is registered"
        @queue.push f
      end

      def cleanup
        transaction do
          @statuses.cleanup
          @dms.cleanup
        end
      end
    end
  end
end

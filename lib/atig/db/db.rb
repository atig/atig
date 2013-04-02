# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'
require 'atig/db/statuses'
require 'atig/db/lists'
require 'atig/util'
require 'thread'
require 'set'
require 'fileutils'

module Atig
  module Db
    class Db
      include Util
      attr_reader :followings, :statuses, :dms, :lists, :noretweets
      attr_accessor :me
      VERSION = 4

      def initialize(context, opt={})
        @log        = context.log
        @me         = opt[:me]
        @tmpdir     = opt[:tmpdir]

        @followings = Followings.new dir('following')
        @statuses   = Statuses.new   dir('status')
        @dms        = Statuses.new   dir('dm')
        @lists      = Lists.new      dir('lists.%s')
        @noretweets = Array.new

        log :info, "initialize"
      end

      def dir(id, tmpdir)
        dir = File.expand_path "atig/#{@me.screen_name}/", @tmpdir
        log :debug, "db(#{id}) = #{dir}"
        FileUtils.mkdir_p dir
        File.expand_path "#{id}.#{VERSION}.db", dir
      end

      def transaction(&f)
        @followings.transaction do|_|
          @statuses.transaction do|_|
            @dms.transaction do|_|
              @lists.transaction do|_|
                f.call self
              end
            end
          end
        end
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

# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module OFilter
    class Footer
      def initialize(context)
        @opts = context.opts
      end

      def call(q)
        if @opts.footer && !@opts.footer.empty? then
          q.merge status: "#{q[:status]} #{@opts.footer}"
        else
          q
        end

      end
    end
  end
end

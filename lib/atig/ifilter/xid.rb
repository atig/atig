
module Atig
  module IFilter
    class Xid
      def initialize(context)
        @opts = context.opts
        c = @opts.send name # expect: 0..15, true, "0,1"
        b = nil
        c, b = c.split(",", 2).map {|i| i.to_i } if c.respond_to? :split
        c = 10 unless (0 .. 15).include? c # 10: teal
        if (0 .. 15).include?(b)
          @format = "\003%.2d,%.2d[%%s]\017" % [c, b]
        else
          @format = "\003%.2d[%%s]\017"      % c
        end
      end

      def call(status)
        xid = status.send name
        unless xid and @opts.send(name)
          status
        else
          status.merge text: "#{status.text} #{@format % xid}"
        end
      end
    end

    class Sid < Xid
      def name; :sid end
    end

    class Tid < Xid
      def name; :tid end
    end
  end
end

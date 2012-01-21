# -*- mode:ruby; coding:utf-8 -*-
# http://subtech.g.hatena.ne.jp/cho45/20091008/1254934083

module Atig
  module Levenshtein
    def levenshtein(a, b)
      PureRuby.levenshtein(a, b)
    end
    module_function :levenshtein

    module PureRuby
      def levenshtein(a, b)
        case
        when a.empty?
          b.length
        when b.empty?
          a.length
        else
          d = Array.new(a.length + 1) { |s|
            Array.new(b.length + 1, 0)
          }

          (0..a.length).each do |i|
            d[i][0] = i
          end

          (0..b.length).each do |j|
            d[0][j] = j
          end

          (1..a.length).each do |i|
            (1..b.length).each do |j|
              cost = (a[i - 1] == b[j - 1]) ? 0 : 1
              d[i][j] = [
                         d[i-1][j  ] + 1,
                         d[i  ][j-1] + 1,
                         d[i-1][j-1] + cost
                        ].min
            end
          end

          d[a.length][b.length]
        end
      end

      module_function :levenshtein
    end
  end
end

#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
# http://subtech.g.hatena.ne.jp/cho45/20091008/1254934083

module Atig
  module Levenshtein
    def levenshtein(a, b)
      if Inline::USABLE
        Inline.levenshtein(a, b)
      else
        PureRuby.levenshtein(a, b)
      end
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

    module Inline
      begin
        require "rubygems"
        require "inline" # sudo gem install RubyInline

        inline do |builder|
          builder.c <<-'EOS'
	    VALUE levenshtein (VALUE array1, VALUE array2) {
	      VALUE ret;
	      long len1 = RARRAY_LEN(array1);
	      long len2 = RARRAY_LEN(array2);
	      long i, j;

	      long** d = ALLOC_N(long*, len1 + 1);
	      for (i = 0; i <= len1; i++) {
		d[i] = ALLOC_N(long, len2 + 1);
		memset(d[i], 0, sizeof(d[i]));
	      }

	      for (i = 1; i <= len1; i++) d[i][0] = i;
	      for (j = 1; j <= len2; j++) d[0][j] = j;
	      for (i = 1; i <= len1; ++i) {
		for (j = 1; j <= len2; ++j) {
		  int del = d[i-1][j  ] + 1;
		  int ins = d[i  ][j-1] + 1;
		  int sub = d[i-1][j-1] + (
					   rb_equal(
						    RARRAY_PTR(array1)[i-1],
						    RARRAY_PTR(array2)[j-1]
						    ) ? 0 : 1
					   );

		  d[i][j] =
		    (del <= ins && del <= sub) ? del:
		    (ins <= del && ins <= sub) ? ins:
		    sub;
		}
	      }

	      ret = LONG2FIX(d[len1][len2]);

	      for (i = 0; i < len1; i++) free(d[i]);
	      free(d);

	      return ret;
          }
          EOS
        end

        module_function :levenshtein

        USABLE = true
      rescue LoadError
        USABLE = false
      end
    end
  end
end

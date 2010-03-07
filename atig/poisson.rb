#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  class Poisson
    def initialize(average)
      @average = average
    end

    def calc(precision)
      i = 0
      sum = 0
      loop do
        sum += poisson(i)
        return i if sum > precision
        i += 1
      end
    end

    private
    def poisson(k)
      Math::E ** ( - @average )  * @average ** k / fact(k)
    end

    def fact(n)
      if n == 0 then
        1
      else
        n * fact(n-1)
      end
    end
  end
end

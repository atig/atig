#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class SizedArray
  def initialize(size)
    @size = size
    @xs = []
  end

  def push(id, x)
    if @xs.find{|item| item[:id] == id } then
      @xs << { :id => id, :entry => x }
    end
    if @xs.size > @size then
      @xs = @xs[-@size..-1]
    end
  end
end

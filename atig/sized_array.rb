#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class SizedArray
  def initialize(size)
    @size = size
    @xs = []
  end

  def include?(id)
    @xs.find{|item| item[:id] == id }
  end

  def push(id, status)
    @xs << {:id => id, :entry => :status}
    if @xs.size > @size then
      @xs = @xs[-@size..-1]
    end
  end
end

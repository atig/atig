#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class SizedArray
  def initialize(size)
    @size = size
    @index = 0
    @xs = []
  end

  def include?(id)
    @xs.find{|item| item.id == id }
  end

  def push(status)
    @xs[@index] = status
    @index = (@index + 1) % @size
  end
  alias_method :<<, :push
end

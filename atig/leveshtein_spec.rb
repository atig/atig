#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'spec'
require 'atig/levenshtein'

[Atig::Levenshtein::Inline, Atig::Levenshtein::PureRuby].each do |m|
  describe m do
    it "should return correct levenshtein distance" do
      [
       ["kitten", "sitting", 3],
       ["foo", "foo", 0],
       ["", "", 0],
       ["foO", "foo", 1],
       ["", "foo", 3],
      ].each do |a, b, expected|
        m.levenshtein(a.split(//), b.split(//)).should == expected
        m.levenshtein(b.split(//), a.split(//)).should == expected
      end
    end
  end
end

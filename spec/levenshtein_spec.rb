# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../spec_helper', __FILE__ )
require 'atig/levenshtein'

target = [Atig::Levenshtein, Atig::Levenshtein::PureRuby]

target.each do |m|
  describe m do
    it "should return correct levenshtein distance" do
      [
       ["kitten", "sitting", 3],
       ["foo", "foo", 0],
       ["", "", 0],
       ["foO", "foo", 1],
       ["", "foo", 3],
       ["あああ", "ああい", 1],
      ].each do |a, b, expected|
        m.levenshtein(a.split(//), b.split(//)).should == expected
        m.levenshtein(b.split(//), a.split(//)).should == expected
      end
    end
  end
end

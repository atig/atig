# -*- mode:ruby; coding:utf-8 -*-

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
        expect(m.levenshtein(a.split(//), b.split(//))).to eq(expected)
        expect(m.levenshtein(b.split(//), a.split(//))).to eq(expected)
      end
    end
  end
end

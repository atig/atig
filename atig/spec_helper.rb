#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

def be_text(text)
  simple_matcher("be text") { |given| given.text.should == text }
end

def status(text,opt={})
  Atig::TwitterStruct.make(opt.merge('text' => text))
end

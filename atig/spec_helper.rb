#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

def be_text(text)
  simple_matcher("be text") { |given| given.text.should == text }
end

def status(text,opt={})
  Atig::TwitterStruct.make(opt.merge('text' => text))
end

def user(id, name)
  user = stub("User-#{name}")
  user.stub!(:id).and_return(id)
  user.stub!(:screen_name).and_return(name)
  user
end

def entry(user,status,name='entry')
  entry = stub name
  entry.stub!('user').and_return(user)
  entry.stub!('status').and_return(status)
  entry
end

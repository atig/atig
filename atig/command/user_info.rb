#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/command'

module Atig
  module Command
    class UserInfo < Atig::Command::Command
      def initialize(*args); super end
      def command_name; %w(bio userinfo) end

      def action(target, mesg, command,args)
        if args.empty?
          yield "/me #{command} <ID>"
          return
        end
        nick,*_ = args

        Info.user(db, api, nick)do|user|
          entry = TwitterStruct.make('user'   => user,
                                     'status' => { 'text' =>
                                       Net::IRC.ctcp_encode(user.description) })
          gateway[target].message entry, Net::IRC::Constants::NOTICE
        end
      end
    end
  end
end

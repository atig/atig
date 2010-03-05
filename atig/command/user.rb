#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
#
# user.rb -
#
# Copyright(C) 2010 by mzp
# Author: MIZUNO Hiroki / mzpppp at gmail dot com
# http://howdyworld.org
#
# Timestamp: 2010/03/04 14:42:21
#
# This program is free software; you can redistribute it and/or
# modify it under MIT Lincence.
#
require "net/irc"
require 'atig/util'
require 'atig/command/single_action'
require 'time'

module Atig
  module Command
    class User < SingleAction
      def initialize(gateway)
        super(gateway,%w(user u))
      end

      def action(target,mesg, command,args)
        if args.empty?
          notify "/me list <NICK> [<NUM>]"
          return
        end
        nick, num,*_ = args

        count = 20 unless (1..200).include?(count = num)
        gateway.api.delay(0) do|t|
          statuses = t.get("statuses/user_timeline", { :count => count, :screen_name => nick})
          gateway.db.transaction do|d|
            statuses.reverse_each do|status|
              d.statuses.add :status => status, :user => status.user, :source => :user
            end
            gateway.db.statuses.find_by_screen_name(nick, :limit=>count).sort{|x,y|
              Time.parse(y.status.created_at) <=> Time.parse(x.status.created_at)
            }.reverse_each do|entry|
              gateway.message(entry, target, Net::IRC::Constants::NOTICE)
            end
          end
        end
      end
    end
  end
end

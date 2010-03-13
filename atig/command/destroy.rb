#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

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
    class Destroy < SingleAction
      def initialize(gateway)
        super(gateway,%w(destroy remove rm))
      end

      def action(target, mesg, command, args)
        statuses = []
        if args.empty?
          entry,_ = gateway.db.statuses.find_by_screen_name(nick, :limit=>1)
          destroy target, entry
        else
          args.each do |tid|
            if entry = find_by_tid(tid)
              if entry.user.id == gateway.db.me.id
                destroy target, entry
              else
                log "The status you specified by the ID tid is not yours."
              end
            else
              log "No such ID tid"
            end
          end
        end
      end

      def destroy(target, entry)
        gateway.api.delay(0) do|t|
          res = t.post("statuses/destroy/#{entry.status.id}")
          gateway.notify target, "Destroyed: #{res.text}"
        end
      end
    end
  end
end

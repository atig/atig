#!/usr/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/search'

module Atig
  module Command
    class Search < Atig::Command::Command
      def command_name; %w(search s) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} [option...] blah blah"
          return
        end

        q = mesg.sub(/^#{command}\s+/, '')
        opts = { :q => q }
        while /^:(?:(lang)=(\w+))/ =~ args.first
           opts[$1] = $2
           q.sub!(/^#{args.first}\W+/, "")
           args.shift
        end

        statuses = api.search.get('search', opts).results

        if statuses.empty?
          yield "\"#{q}\": not found. options=#{opts.inspect} (#{res['completed_in']} sec.)"
          return
        end

        db.transaction do|d|
          statuses.reverse_each do|status|
            user = TwitterStruct.make('id'          => status.from_user_id,
                                      'screen_name' => status.from_user)
            d.statuses.add :status => status, :user => user, :source => :user
          end

          statuses.reverse_each do|status|
            entry = db.statuses.find_by_status_id(status.id)
            gateway[target].message entry, Net::IRC::Constants::NOTICE
          end
        end
      end
    end
  end
end

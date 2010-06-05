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

        res = api.search.get('search', opts)

        if res['results'].empty?
          yield "\"#{q}\": not found. options=#{opts.inspect} (#{res['completed_in']} sec.)"
          return
        end

        res['results'].reverse.each do |tw|
          # TODO: 検索結果にも tid/sid を振りたい
          entry = TwitterStruct.make('user'   => {
                                       'id' => tw.from_user_id  ,
                                       'screen_name' => tw.from_user
                                     },
                                     'status' => { 'text' =>
                                       Net::IRC.ctcp_encode("#{tw['text']} (#{tw['created_at']})") })
          gateway[target].message entry, Net::IRC::Constants::NOTICE
        end
      end
    end
  end
end

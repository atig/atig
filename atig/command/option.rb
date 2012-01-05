# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/command'
require 'atig/option'

module Atig
  module Command
    class Option < Atig::Command::Command
      def initialize(*args)
        super
        @methods = OpenStruct.instance_methods
      end

      def command_name; %w(opt opts option options) end

      def action(target, mesg, command, args)
        if args.empty?
          @opts.fields.
            map{|x| x.to_s }.
            sort.each do|name|
              yield "#{name} => #{@opts[name]}"
          end
        else
          _,name,value = mesg.split ' ', 3
          unless value then
            # show the value
            yield "#{name} => #{@opts.send name}"
          else
            # set the value
            @opts.send "#{name}=",::Atig::Option.parse_value(value)
            yield "#{name} => #{@opts.send name}"
          end
        end
      end
    end
  end
end

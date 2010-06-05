#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'pp'
require 'logger'

$KCODE = "u" unless defined? ::Encoding # json use this
Dir.chdir(File.dirname(__FILE__))

case
when File.directory?("lib")
  $LOAD_PATH << "lib"
when File.directory?(File.expand_path("lib", ".."))
  $LOAD_PATH << File.expand_path("lib", "..")
end

require 'atig/twitter'
require 'atig/scheduler'

Dir['atig/agent/*.rb'].each do|file|
  load file
end

Dir['atig/ifilter/*.rb'].each do|file|
  require file unless file =~ /_spec.rb\Z/
end

Dir['atig/ofilter/*.rb'].each do|file|
  require file unless file =~ /_spec.rb\Z/
end

Dir['atig/command/*.rb'].each do|file|
  require file unless file =~ /(?:_spec\.rb|_helper\.rb)\Z/
end

Dir['atig/channel/*.rb'].each do|file|
  require file
end

require 'atig/gateway/session'

Atig::Gateway::Session.agents   = [
                                   Atig::Agent::List,
                                   Atig::Agent::Following,
                                   Atig::Agent::ListStatus,
                                   Atig::Agent::Mention,
                                   Atig::Agent::Dm,
                                   Atig::Agent::Timeline,
                                   Atig::Agent::StreamFollow,
                                  ]
Atig::Gateway::Session.ifilters = [
                                   Atig::IFilter::Retweet,
                                   Atig::IFilter::Utf7,
                                   Atig::IFilter::Sanitize,
                                   Atig::IFilter::ExpandUrl,
                                   Atig::IFilter::Strip.new(%w{ *tw* *Sh*}),
                                   Atig::IFilter::Tid,
                                   Atig::IFilter::Sid
                                  ]
Atig::Gateway::Session.ofilters = [
                                   Atig::OFilter::EscapeUrl,
                                   Atig::OFilter::ShortUrl,
                                   Atig::OFilter::Geo,
                                   Atig::OFilter::Footer,
                                  ]
Atig::Gateway::Session.commands = [
                                   Atig::Command::Retweet,
                                   Atig::Command::Reply,
                                   Atig::Command::User,
                                   Atig::Command::Favorite,
                                   Atig::Command::Uptime,
                                   Atig::Command::Destroy,
                                   Atig::Command::Status,
                                   Atig::Command::Thread,
                                   Atig::Command::Time,
                                   Atig::Command::Version,
                                   Atig::Command::UserInfo,
                                   Atig::Command::Whois,
                                   Atig::Command::Option,
                                   Atig::Command::Location,
                                   Atig::Command::Name,
                                   Atig::Command::Autofix,
                                   Atig::Command::Limit,
                                   Atig::Command::Search,
                                  ]
Atig::Gateway::Session.channels = [
                                   Atig::Channel::Timeline,
                                   Atig::Channel::Mention,
                                   Atig::Channel::Dm,
                                   Atig::Channel::List,
                                   Atig::Channel::Retweet,
                                  ]

if __FILE__ == $0
  require "optparse"

  opts = {
    :port  => 16668,
    :host  => "localhost",
    :log   => nil,
    :debug => false,
    :foreground => false,
    :conf => '~/.atig/config',
  }

  OptionParser.new do |parser|
    parser.instance_eval do
      self.banner = <<EOB.gsub(/^\t+/, "")
Usage: #{$0} [opts]
EOB
      separator ""

      separator "Options:"
      on("-p", "--port [PORT=#{opts[:port]}]", "port number to listen") do |port|
        opts[:port] = port
      end

      on("-h", "--host [HOST=#{opts[:host]}]", "host name or IP address to listen") do |host|
        opts[:host] = host
      end

      on("-l", "--log LOG", "log file") do |log|
        opts[:log] = log
      end

      on("--debug", "Enable debug mode") do |debug|
        opts[:log]   ||= $stderr
        opts[:debug]   = true
      end

      on("--memprof", "Enable memory profiler") do|_|
        require 'memory_profiler'
        require 'fileutils'
        FileUtils.mkdir_p "log"
        MemoryProfiler.start(:string_debug => true)
      end

      on("-c","--conf [file=#{opts[:conf]}]", "atig configuration file; default is '~/.atig/config'") do|name|
        opts[:conf] = name
      end

      parse!(ARGV)
    end
  end

  opts[:logger] = Logger.new(opts[:log], "weekly")
  opts[:logger].level = opts[:debug] ? Logger::DEBUG : Logger::INFO

  conf = File.expand_path opts[:conf]
  if  File.exist? conf then
    opts[:logger].info "Loading #{conf}"
    load conf
  end

  Net::IRC::Server.new(opts[:host], opts[:port], Atig::Gateway::Session, opts).start
end

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
  load file
end

Dir['atig/ofilter/*.rb'].each do|file|
  load file
end

require 'atig/database'
require 'atig/gateway'

Atig::Gateway.agents   = [ Atig::Agent::Timeline ]
Atig::Gateway.ifilters = [ Atig::IFilter::DecodeUtf7,
                           Atig::IFilter::Sanitize,
                           Atig::IFilter::ExpandUrl,
                           Atig::IFilter::Strip.new(%w{ *tw* }),
                           Atig::IFilter::Retweet,
                           Atig::IFilter::Tid
                         ]
Atig::Gateway.ofilters = [
                          Atig::OFilter::EscapeUrl,
                          Atig::OFilter::ShortUrl,
                         ]

if __FILE__ == $0
  require "optparse"

  opts = {
    :port  => 16668,
    :host  => "localhost",
    :log   => nil,
    :debug => false,
    :foreground => false,
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
        opts[:log]   = $stderr
        opts[:debug] = true
      end

      on("-f", "--foreground", "run foreground") do |foreground|
        opts[:log]        = $stderr
        opts[:foreground] = true
      end

      on("-n", "--name [user name or email address]") do |name|
        opts[:name] = name
      end

      parse!(ARGV)
    end
  end

  opts[:logger] = Logger.new(opts[:log], "daily")
  opts[:logger].level = opts[:debug] ? Logger::DEBUG : Logger::INFO
  Net::IRC::Server.new(opts[:host], opts[:port], Atig::Gateway, opts).start
end

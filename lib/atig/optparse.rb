require "optparse"
require 'tmpdir'

module Atig
  module OptParser
    class << self
      def parse!(argv)
        opts = {
          :port  => 16668,
          :host  => "localhost",
          :log   => nil,
          :debug => false,
          :foreground => false,
          :tmpdir => ::Dir.tmpdir,
          :conf => '~/.atig/config',
        }

        OptionParser.new do |parser|
          parser.instance_eval do
            self.banner = <<EOB.gsub(/^\t+/, "")
usage: #{$0} [opts]
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

            on("--tmpdir", "temporary directory path") do |tmp|
              opts[:tmpdir] = tmp
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

            parse!(argv)
          end
        end

        opts
      end
    end
  end
end

require 'logger'

module Atig
  module Client
    class << self
      def run
        opts = Atig::OptParser.parse!(ARGV)

        opts[:logger] = Logger.new(opts[:log], "weekly")
        opts[:logger].level = opts[:debug] ? Logger::DEBUG : Logger::INFO

        conf = File.expand_path opts[:conf]
        if File.exist? conf then
          opts[:logger].info "Loading #{conf}"
          load conf
        end

        Net::IRC::Server.new(opts[:host], opts[:port], Atig::Gateway::Session, opts).start
      end
    end
  end
end

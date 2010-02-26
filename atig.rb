require 'rubygems'
require 'pp'

require 'logger'
require 'atig/twitter'
require 'atig/scheduler'
require 'atig/agent/timeline'
require 'atig/database'
require 'atig/gateway'

logger = Logger.new(STDERR)
logger.level = Logger::DEBUG

include Atig

# FIXME: use OAuth
twitter = Twitter.new(logger,'nzp','madpro')

s = Scheduler.new logger, twitter
db = Database.new logger

Agent::Timeline.new(logger, s, db)

Gateway.new(logger, s, db)

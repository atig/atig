require 'logger'
require 'atig/scheduler'
require 'atig/timeline'
require 'atig/database'
require 'atig/gateway'

logger = Logger.new(STDERR)

include Atig
s = Scheduler.new logger
db = Database.new logger

# recv
Timeline.new(logger, s, db)
Gateway.new(logger, s, db)


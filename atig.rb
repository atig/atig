require 'atig/scheduler'
require 'atig/timeline'
require 'atig/database'
require 'atig/gateway'

include Atig
s = Scheduler.new
db = Database.new

# recv
Timeline.new(s, db)
Gateway.new(s, db)


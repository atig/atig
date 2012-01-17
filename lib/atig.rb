# -*- coding: utf-8 -*-
$KCODE = "u" unless defined? ::Encoding # json use this

require 'rubygems'
require 'sqlite3'
require 'net/irc'
require 'oauth'
require 'json'

require 'atig/version'
require 'atig/monkey'
require 'atig/twitter'
require 'atig/scheduler'
require 'atig/gateway/session'

require 'atig/agent/full_list'
require 'atig/agent/following'
require 'atig/agent/list_status'
require 'atig/agent/mention'
require 'atig/agent/dm'
require 'atig/agent/timeline'
require 'atig/agent/clenup'
require 'atig/agent/user_stream'

Atig::Gateway::Session.agents   = [
                                   Atig::Agent::FullList,
                                   Atig::Agent::Following,
                                   Atig::Agent::ListStatus,
                                   Atig::Agent::Mention,
                                   Atig::Agent::Dm,
                                   Atig::Agent::Timeline,
                                   Atig::Agent::Cleanup,
                                   Atig::Agent::UserStream,
                                  ]

require 'atig/ifilter/retweet'
require 'atig/ifilter/retweet_time'
require 'atig/ifilter/utf7'
require 'atig/ifilter/sanitize'
require 'atig/ifilter/expand_url'
require 'atig/ifilter/strip'
require 'atig/ifilter/xid'

Atig::Gateway::Session.ifilters = [
                                   Atig::IFilter::Retweet,
                                   Atig::IFilter::RetweetTime,
                                   Atig::IFilter::Utf7,
                                   Atig::IFilter::Sanitize,
                                   Atig::IFilter::ExpandUrl,
                                   Atig::IFilter::Strip.new(%w{ *tw* *Sh*}),
                                   Atig::IFilter::Tid,
                                   Atig::IFilter::Sid
                                  ]

require 'atig/ofilter/escape_url'
require 'atig/ofilter/short_url'
require 'atig/ofilter/geo'
require 'atig/ofilter/footer'

Atig::Gateway::Session.ofilters = [
                                   Atig::OFilter::EscapeUrl,
                                   Atig::OFilter::ShortUrl,
                                   Atig::OFilter::Geo,
                                   Atig::OFilter::Footer,
                                  ]

require 'atig/command/retweet'
require 'atig/command/reply'
require 'atig/command/user'
require 'atig/command/favorite'
require 'atig/command/uptime'
require 'atig/command/destroy'
require 'atig/command/status'
require 'atig/command/thread'
require 'atig/command/time'
require 'atig/command/version'
require 'atig/command/user_info'
require 'atig/command/whois'
require 'atig/command/option'
require 'atig/command/location'
require 'atig/command/name'
require 'atig/command/autofix'
require 'atig/command/limit'
require 'atig/command/search'
require 'atig/command/refresh'
require 'atig/command/spam'
require 'atig/command/dm'

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
                                   Atig::Command::Refresh,
                                   Atig::Command::Spam,
                                   Atig::Command::Dm,
                                  ]

require 'atig/channel/timeline'
require 'atig/channel/mention'
require 'atig/channel/dm'
require 'atig/channel/list'
require 'atig/channel/retweet'

Atig::Gateway::Session.channels = [
                                   Atig::Channel::Timeline,
                                   Atig::Channel::Mention,
                                   Atig::Channel::Dm,
                                   Atig::Channel::List,
                                   Atig::Channel::Retweet,
                                  ]

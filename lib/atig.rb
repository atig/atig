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
require 'atig/agent'
require 'atig/ifilter'
require 'atig/ofilter'
require 'atig/command'
require 'atig/channel'
require 'atig/gateway'

Atig.rb - Another Twitter Irc Gateway
===========================================

[![Gem Version](https://badge.fury.io/rb/atig.svg)](https://rubygems.org/gems/atig) [![Build Status](https://travis-ci.org/atig/atig.svg)](https://travis-ci.org/atig/atig) [![Coverage Status](https://coveralls.io/repos/github/atig/atig/badge.svg?branch=master)](https://coveralls.io/github/atig/atig?branch=master) [![Code Climate](https://codeclimate.com/github/atig/atig.svg)](https://codeclimate.com/github/atig/atig)

OVERVIEW
--------
Atig.rb is Twitter Irc Gateway.

Atig.rb is forked from cho45's tig.rb. We improve some features of tig.rb.

PREREQUISITES
-------------

* Ruby 1.9.3 or later
* sqlite3-ruby
* rspec(for unit test)
* rake(for unit test)

HOW TO USE
----------

You type:

    $ cd atig
    $ bin/atig -d
    I, [2010-04-05T07:22:07.861527 #62002]  INFO -- : Host: localhost Port:16668

and access localhost:16668 by Irc client.

DOCUMENTS
---------
See `docs/`, if you could read Japanese.

BRANCH POLICY
-------------

 * master: a branch for current release.
 * testing: a branch for next release.
 * other branches: feature branch

LICENCE
-------
This program is free software; you can redistribute it and/or
modify it under Ruby Lincence.

AUTHOR
------
MIZUNO "mzp" Hiroki (mzp@happyabc.org)

AVAILABILITY
------------
The complete atig.rb distribution can be accessed at this[https://atig.github.io/]..

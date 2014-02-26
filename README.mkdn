Atig.rb - Another Twitter Irc Gateway
===========================================

[![Gem Version](https://badge.fury.io/rb/atig.png)](https://rubygems.org/gems/atig) [![Code Climate](https://codeclimate.com/github/atig/atig.png)](https://codeclimate.com/github/atig/atig) [![Build Status](https://travis-ci.org/atig/atig.png)](https://travis-ci.org/atig/atig)

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
The complete atig.rb distribution can be accessed at this[http://mzp.github.com/atig/]..

$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit/assertions'
World(Test::Unit::Assertions)

require 'bug'
require 'bug_cache'
require 'fix_cache'
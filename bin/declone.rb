#! /user/bin/env ruby

require_relative '../src/decloner'

decloner = Decloner.new

p decloner.get_common ARGV[1], ARGV[2]
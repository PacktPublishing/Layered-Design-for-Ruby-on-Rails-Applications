# frozen_string_literal: true

require 'bundler/inline'

# Gemfile
gemfile(true, quiet: true) do
  source 'https://rubygems.org'

  gem 'activemodel', '~> 7'
  gem 'benchmark-ips'
  gem 'benchmark-memory'
end

require 'active_model'
require 'benchmark/memory'
require 'benchmark/ips'

class ActiveUser
  include ActiveModel::API

  attr_accessor :a, :b, :c, :d, :e
end

class ActiveAttributesUser
  include ActiveModel::API
  include ActiveModel::Attributes

  %i[a b c d e].each { attribute _1 }
end

StructUser = Struct.new(:a, :b, :c, :d, :e, keyword_init: true)

Benchmark.ips do |x|
  x.report('struct') { StructUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }
  x.report('active model api') { ActiveUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }
  x.report('w/attributes') { ActiveAttributesUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }

  x.compare!
end

Benchmark.memory do |x|
  x.report('struct') { StructUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }
  x.report('active model api') { ActiveUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }
  x.report('w/attributes') { ActiveAttributesUser.new(a: 1, b: 2, c: 3, d: 4, e: 5) }

  x.compare!
end

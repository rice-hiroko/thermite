# -*- coding: utf-8 -*-
require 'English'

Gem::Specification.new do |s|
  s.name        = 'thermite'
  s.version     = '0.0.1'
  s.summary     = 'Rake helpers for Rust+Ruby'
  s.description = 'A Rake-based helper for building and distributing Rust-based Ruby extensions'

  s.authors     = ['Mark Lee']
  s.email       = 'malept@users.noreply.github.com'
  s.homepage    = 'https://github.com/malept/thermite'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  s.require_paths = %w(lib)

  s.add_runtime_dependency 'rake', '~> 11'
  s.add_runtime_dependency 'fpm', '~> 1.5'
  s.add_runtime_dependency 'tomlrb', '~> 1.2'
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data_grid/version'

Gem::Specification.new do |gem|
  gem.name          = "data_grid"
  gem.version       = DataGrid::VERSION
  gem.authors       = ["Krzysztof Kempiński"]
  gem.email         = ["kkempin@gmail.com"]
  gem.description   = %q{This gem generates configurable grids for Rails applications}
  gem.summary       = %q{data grid tool for Rails applications}
  gem.homepage      = "https://github.com/kkempin/data_grid"

  gem.required_rubygems_version = ">= 1.3.6"
  gem.add_dependency "rails", ">= 3.0"
  gem.add_dependency "fastercsv"
  gem.add_development_dependency "bundler", ">= 1.0.0"
  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "sqlite3"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end

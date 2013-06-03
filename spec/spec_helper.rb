$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
 
ENV["RAILS_ENV"] ||= 'test'
 
require "rails/all"

require 'rspec/rails'
 
root = File.expand_path(File.dirname(__FILE__))
 
RSpec.configure do |config|
end
 
require 'data_grid'

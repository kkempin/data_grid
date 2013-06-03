require 'active_record'
require 'rspec/rails/extensions/active_record/base'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Migration.create_table :users do |t|
  t.string :name
  t.timestamps
end

class User < ActiveRecord::Base
end

1.upto(50) do |i|
  User.create({
    :name => "John_#{i}"
  })
end

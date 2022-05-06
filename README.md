[![Build Status](https://travis-ci.org/harrystech/seed_migration.svg?branch=master)](https://travis-ci.org/harrystech/seed_migration) [![Gem Version](https://badge.fury.io/rb/seed_migration.svg)](http://badge.fury.io/rb/seed_migration) [![Code Climate](https://codeclimate.com/repos/565d2ab865f101004800136a/badges/22e9c1da0befd44cac82/gpa.svg)](https://codeclimate.com/repos/565d2ab865f101004800136a/feed) [![Test Coverage](https://codeclimate.com/repos/565d2ab865f101004800136a/badges/22e9c1da0befd44cac82/coverage.svg)](https://codeclimate.com/repos/565d2ab865f101004800136a/coverage)

# SeedMigration

Harry's Data Migrations are a way to manage changes to seed data in a rails app in a similar way to how schema migrations are handled.


## Intro
A data migration library, similar to rails built-in schema migration. It also auto generates a `db/seeds.rb` file, similar to how schema migrations generate the `db/schema.rb` file.
Using this auto generated seed file makes it quick and easy to setup new environments, usually development or test.

## Installation

Add `gem 'seed_migration'` to your `Gemfile`:

```ruby
gem 'seed_migration'
```

## Usage

### Install and run the internal migrations

```
rake seed_migration:install:migrations
rake db:migrate
```

That will create the table to keep track of data migrations.

### Generate a new migration

You can use the generator :

```
rails g seed_migration AddFoo
```
A new file will be created under `db/data/` using rails migration convention:

```
db/data/20140407162007_add_foo.rb
```

You'll need to implement the `#up` method and if you need to be able to rollback, the `#down` method.

### Running the migrations

To run all pending migrations, simply use

```
rake seed:migrate
```

If needed, you can run a specific migration:

```
rake seed:migrate MIGRATION=20140407162007_add_foo.rb
```

### Rollback

Rolling back the last migration is as simple as:

```
rake seed:rollback
```

You can rollback more than one migration at the same time:

```
rake seed:rollback STEP=3 # rollback last 3 migrations
```

Or rollback a specific migration:

```
rake seed:rollback MIGRATION=20140407162007_add_foo.rb
```

### Status

See the status of your migrations:

```
rake seed:migrate:status
```

Example output:

```
database: seed-migrationdevelopment

 Status   Migration ID    Migration Name
--------------------------------------------------
   up     20160114153832  Add users
  down    20160114153843  Add more users
  down    20160114153851  Add even more users
```

### Registering models

By default no models are registered, so running seed migrations won't update the seeds file.
You have to manually register the models in the configuration file.

Simply register a model:

```ruby
SeedMigration.register Product
```

You can customize the 'seeded' attribute list:

```ruby
SeedMigration.register User do
  exclude :id, :password
end
```

This will create a `seeds.rb` containing all User and Product in the database:

```ruby
# encoding: UTF-8
# This file is auto-generated from the current content of the database. Instead
# of editing this file, please use the migrations feature of Seed Migration to
# incrementally modify your database, and then regenerate this seed file.
#
# If you need to create the database on another system, you should be using
# db:seed, not running all the migrations from scratch. The latter is a flawed
# and unsustainable approach (the more migrations you'll amass, the slower
# it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Base.transaction do
  Product.create("created_at"=>"2014-04-04T15:42:24Z", "id"=>1, "name"=>"foo", "updated_at"=>"2014-04-04T15:42:24Z")
  Product.create("created_at"=>"2014-04-04T15:42:24Z", "id"=>2, "name"=>"bar", "updated_at"=>"2014-04-04T15:42:24Z")
  # ...
  User.create("created_at"=>"2014-04-04T15:42:24Z", "id"=>1, "name"=>"admin", "updated_at"=>"2014-04-04T15:42:24Z")
  # ...
end

SeedMigration::Migrator.bootstrap(20140404193326)
```

Note that `seeds.rb` is only generated in development mode.  Production data will not be dumped in this process.

### Checking for pending migrations

Check for pending data migrations:

```ruby
SeedMigration::Migrator.check_pending!
```

If there are pending migrations, this will raise
`SeedMigration::Migrator::PendingMigrationError`.

### Adding seed_migrations to an existing app

If your app already contains seeds, using this gem could cause some issues.
Here is the basic process to follow to ensure a smooth transition:

- Clean your local database, and seed it, that can be done with `rake db:reset`
- register all the models that were created in the original seeds file
- run `rake seed:migrate`
- At this point, your seeds file will be rewritten with all the `create` statements
- Commit/Push the updated seeds file

### Deployment notes

It is recommended to add the `rake seed:migrate` to your deploy script, so each new data migrations is ran upon new deploys.
You can enable the `extend_native_migration_task` option to automatically run `rake seed:migrate` after `rake db:migrate`.

For Capistrano 3.x support, add this to your Capfile

```ruby
require 'capistrano/seed_migration_tasks'
```

which provides the two cap tasks, which you can add to your deploy script or run on the command line:

```ruby
cap {stage} seed:migrate
cap {stage} seed:rollback
```

## Example

```ruby
rails g seed_migration AddADummyProduct
```

```ruby
class AddADummyProduct < SeedMigration::Migration
    def up
        Product.create!({
            :asset_path => "valentines-day.jpg",
            :title => "Valentine's Day II: the revenge!",
            :active => false,
            :default => false,
        }, :without_protection => true)
    end

    def down
        Product.destroy_all(:title => "Valentine's Day II: the revenge!")
    end
end
```

## Disable Transactions

Support has been added for disabling transactions for long running migrations.
Since a long running migration can lock a table in production, transactions are
disabled by default. You should always try to write idempotent migrations,
but if you can't, you can either add transaction blocks manually in your migration,
or if you just want to enable a transaction around the whole migration, you can
call `use_transaction!`.

```ruby
class ChangeABunchOfJobs < SeedMigration::Migration

  use_transaction!

  def up
    ...
  end

  def down
  end

end
```

## Configuration

Use an initializer file for configuration.

### List of available configurations :

- `extend_native_migration_task (default=false)`
- `ignore_ids (default=false)`
- `migration_table_name (default='seed_migration_data_migrations')`: Override the table name for the internal model that holds the migrations
- `use_strict_create (default=false)`: Use `create!` instead of `create` in `db/seeds.rb` when set to true

#### example:

```ruby
# config/initializers/seed_migration.rb

SeedMigration.config do |c|
    c.migration_table_name = 'data_migrations'
    c.extend_native_migration_task = true
end

SeedMigration.register User do
  exclude :id, :password
end
SeedMigration.register Product
```

## Compatibility

At the moment, we rely by default on

```ruby
ActiveRecord::Base.connection.reset_pk_sequence!
```
which is `pg` only.

If you need to use this gem with another database, use the `ignore_ids` configuration.


## Runnings tests


```
RAILS_ENV=test bundle exec rake app:db:reset
bundle exec rspec spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

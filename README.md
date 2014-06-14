[![Build Status](https://travis-ci.org/harrystech/seed_migration.svg?branch=master)](https://travis-ci.org/harrystech/seed_migration) [![Gem Version](https://badge.fury.io/rb/seed_migration.svg)](http://badge.fury.io/rb/seed_migration)

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

```ruby
rake seed_migration:install:migrations
rake db:migrate
```

That will create the table to keep track of data migrations.

### Generate a new migration

You can use the generator :

```ruby
rails g seed_migration AddFoo
```
A new file will be created under `db/data/` using rails migration convention:

```
db/data/20140407162007_add_foo.rb
```

You'll need to implement the `#up` method and if you need to be able to rollback, the `#down` method.

### Running the migrations

To run all pending migrations, simply use

```ruby
rake seed:migrate
```

If needed, you can run a specific migration:

```ruby
rake seed:migrate MIGRATION=20140407162007_add_foo.rb
```

### Rollback

Rolling back the last migration is as simple as:

```ruby
rake seed:rollback
```

You can rollback more than one migration at the same time:

```ruby
rake seed:rollback STEPS=3 # rollback last 3 migrations
```

Or rollback a specific migration:

```ruby
rake seed:rollback MIGRATION=20140407162007_add_foo.rb
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
# If you need to create see the database on another system, you should be using
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

### Adding seed_migrations to an existing app

If your app already contains seeds, using this gem could cause some issues.
Here is the basic process to follow to ensure a smooth transition:

- Clean your local database, and seed it, that can be done with `rake db:reset`
- register all the models that were created in the original seeds file
- run `rake seed:migrate`
- At this point, your seeds file will be rewritten with all the `create!` statements
- Commit/Push the updated seeds file

### Deployment notes

It is recommended to add the `rake seed:migrate` to your deploy script, so each new data migrations is ran upon new deploys.
You can enable the `extend_native_migration_task` option to automatically run `rake seed:migrate` after `rake db:migrate`.

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

## Configuration

Use an initializer file for configuration.

### List of available configurations :

- `extend_native_migration_task (default=false)`
- `ignore_ids (default=false)`
- `migration_table_name (default='seed_migration_data_migrations')`: Override the table name for the internal model that holds the migrations

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

## Schema conflicts

SeedMigration is built to work with your schema updates, as they are common in
most systems.  Here is an example to illustrate how to deal with schema
updates:

#### Initial setup

Let's take one seeded model: `Product`, with three columns `id, name,
description`.

You write your first seed migration, to capitalize all products' name:

`rails g seed_migration CapitalizeProducts`

```ruby
# db/data/20140604185727_capitalize_products.rb
class CapitalizeProducts < SeedMigration::Migration
  def up
    Product.all.each { |p| p.update_attributes(:name => p.name.capitalize) }
  end

  def down
    # Let's ignore down in that example
  end
end
```

The database has a few products, so after running `seed:migrate` for the first
time, your seeds file should look something like:

```ruby
...
Product.create(:id=>1,:name=>"Prod1",:description=>"Desc for prod1...")
Product.create(:id=>2,:name=>"Prod2",:description=>"Desc for prod2 ...")
...
SeedMigration::Migrator.bootstrap(20140604185727)
```

The timestamp passed to the bootstrap method identifies the last migration ran
(note that it is the same timestamp used in the migration's file name).  So if
you want to bootstrap a new environment, running `rake db:seed` will create all
Product and then will mark all the migrations up to 20140604185727 as applied.
That means that running `seed:migrate` won't run anything as the migration is
considered already applied.

#### Updating the schema

Let's imagine that, for some reasons, you want to remove products' name, you
write a rails migrations that drops the column from the `products` table.
After running this schema migration, your seeds file is broken and your seed
migration are broken as they operate on a non existing column: `name`.

The solution to fix it is to run `rake seed:migrate`. Even if it won't run any
seed migrations (the only seed migration is already marked as applied), it will
update the seeds file with the current content of your datase. So the seeds
file would look something like.

```ruby
...
Product.create(:id=>1,:description=>"Desc for prod1 ...")
Product.create(:id=>2,:description=>"Desc for prod2 ...")
...
SeedMigration::Migrator.bootstrap(20140604185727)
```

The column `name` does not appear in the seeds anymore.

Now that the seeds file is fixed you can safely use it to bootstrap a new
environment.

#### Applying changes to a production environment

We never ended up in a situation where a seed migration would error on a
production environment, though it is possible to create such a situation.

In our previous example, if the migration that drops the name column is ran
before the seed migration that updates the name, then it wouldn't be possible
to run the seed migration anymore.  In such situations this would be an
indicator that the seed migrations is outdated, and should be deleted or
updated.

## Compatibility

At the moment, we rely by default on

```
ActiveRecord::Base.connection.reset_pk_sequence!
```
which is `pg` only.

If you need to use this gem with another database, use the `ignore_ids` configuration.


## Runnings tests


```ruby
RAILS_ENV=test bundle exec rake app:db:reset
bundle exec rspec spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

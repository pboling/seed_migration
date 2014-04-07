TODO : Add travis configuration, and then badge, eventually gemfury badge too.

# SeedMigration

Harry's Data Migrations are a way to manage changes to seed data in a rails app in a similar way to how schema migrations are handled.


## Intro
A data migration library, similar to rails built-in schema migration. It also auto generates a `db/seeds.rb` file, similar to how schema migrations generate the `db/schema.rb` file.
Using this auto generated seed file makes it quick and easy to setup new environments, usually development or test.

## Installation

Add `gem 'seed_migration'` to your `Gemfile`:

```ruby
gem 'seed_migration', :github => 'harrystech/seed_migration'
```

Note : It'll soon be released on rubygems.org.

## Usage

### Generate a new migration

`SeedMigration` adds a new rails generator :

```ruby
rails g seed_migration:migration AddFoo
```
A new file will be created under `db/data/` using rails migration convention:

```
db/data/20140407162007_add_foo.rb
```

You'll need to implement the `#up` method and if you need to be able to rollback, the `#down` method.

### Running the migrations

To run all pending migrations, simply use

```ruby
rake data:migrate
```

If needed, you can run a specific migration:

```ruby
rake data:migrate MIGRATION=20140407162007_add_foo.rb
```

### Rollback

Rolling back the last migration is as simple as:

```ruby
rake data:rollback
```

You can rollback more than one migration at the same time:

```ruby
rake data:rollback STEPS=3 # rollback last 3 migrations
```

Or rollback a specific migration:

```ruby
rake data:rollback MIGRATION=20140407162007_add_foo.rb
```

### Deployment notes

It is recommended to add the `rake data:migrate` to your deploy script, so each new data migrations is ran upon new deploys.
You can enable the `extend_native_migration_task` option to automatically run `rake data:migrate` after `rake db:migrate`.

## Example

```ruby
rails g seed_migration:migration AddADummyProduct
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

`SeedMigration` can be configured using an initializer file.

### List of available configurations :

- `extend_native_migration_task (default=false)`
- `pending_migrations_warning_level (default=:warn)`
- `ignore_ids (default=false)`
- `migration_table_name (default='seed_migration_data_migrations')`: Override the table name for the internal model that holds the migrations

#### example:

```ruby
# config/initializers/seed_migration.rb

SeedMigration.config do |c|
    c.migration_table_name = 'data_migrations'
    c.extend_native_migration_task = true
    c.pending_migrations_warning_level = :error
end
```

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

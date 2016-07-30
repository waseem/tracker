Campaign Tracker
========

Structure
---------

`app/app.rb`        - Sinatra application.
`db/config.rb`      - Database configuration.
`db/migrate`        - Schema migration files.
`boot.rb`           - Add project specific directories to `$LOAD_PATH`
`script/seeds.rb`   - Creates initial database.
`data`              - JSON for initial seed data.
`app/cache.rb`      - Basic cache.
`app/key_hasher.rb` - Module that provides hashing functions for cached keys.

Starting the Application
---------

First clone the application to your machine with git. The `cd` into the project directory and do following:

1. Install all the gems
  `bundle install`

2. Create database in your local MySQL server.
  `mysql> CREATE DATABASE tracker_development`

3. Change the settings in `db/config.yml` according to your local MySQL database server.

4. Migrate the database.
  `bundle exec rake db:migrate`

5. Populate the database with intial data
  `bundle exec ruby script/seeds.rb`

6. Start the server
  `bundle exec ruby app/app.rb`

7. Visit a Shortlink in your browser like *localhost:4567/123* (`123` is id) or *localhost:4567/foo* (`foo` is slug).

Executing Tests
---------

1. Create test database in your local MySQL server.
  `mysql> CREATE DATABASE tracker_test`

2. Migrate the database.
  `RACK_ENV=test bundle exec rake db:migrate`

3. Run all tests
  `bundle exec rspec spec`

Notes
---------

Loading database models in irb
---------

You can load up the models in `app/models` in your irb session by doing following.

  `irb> require '/path/to/boot'`
  `irb> require 'database'`
  `irb> Shortlink.first`

Seeding the Database
---------

- There is `data/campaigns.json` and `data/shortlinks.json` in which you can add new records that could be loaded in the database with `bundle exec ruby script/seeds.rb`.

- When adding new records you'll have to reacreate the entire database. (I'm not improving on this front. Ideally there should be a way for users to enter campaigns and corresponding shortlinks).

- Always add new records to `data/campaigns.json` or `data/shortlink.json` at the bottom of the JSON. This is because value in `id` column is generated automatically by `ActiveRecord`. In case you move around the records in JSON and then seed the database, references in `shortlink.json (campaign_id )` won't reference the intended record in `campaigns.json` that you want to.

- I have not created columns in `campaigns` table for attributes `visibility_status`, `scheduled_pause_at`, `priority`, `store_id`, `rpc_coins`, `rpc_usd`, `ppc_coins`, `ppc_usd`, `preview_url` and `tenant_id`. These attributes did not pertain to problem set.

- `shortlinks` table does not have columns pertaining to `shortlink_id` and `user_id` because these attributes did not pertain to the problem set.


Cache
---------

`app/cache.rb` contains basic caching mechanism for the shortlinks. Once you start the application, you can observe the cache hit and misses in `log/development.log`.

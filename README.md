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
`config/cache.yml`  - Cache specific configuration. (for expiration time of objects)
`config/resque.yml` - Connections settings for Redis used by our Queue processor

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

6. Start the Redis server
   `redis-server`

7. Start the Queue processors
   `QUEUE=* VERBOSE=true PIDFILE=/tmp/resque0.pid bundle exec rake environment resque:work --trace`

8. Start the server
  `bundle exec ruby app/app.rb`

9. Visit a Shortlink in your browser like *localhost:4567/123* (`123` is id) or *localhost:4567/foo* (`foo` is slug).

10. Visit *localhost:4567/dashboard* for information on Queue and Cache.

Executing Tests
---------

1. Create test database in your local MySQL server.
  `mysql> CREATE DATABASE tracker_test`

2. Migrate the database.
  `RACK_ENV=test bundle exec rake db:migrate`

3. Start the Redis server
   `redis-server`

7. Start the Queue processors (Optional)
   `RACKE_ENV=test QUEUE=* VERBOSE=true PIDFILE=/tmp/resque0.pid bundle exec rake environment resque:work --trace`

4. Run all tests
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

- `app/cache.rb` contains basic caching mechanism for the shortlinks. Once you start the application, you can observe the cache hit and misses in `log/development.log`.

- You can change the value of `expire_after` for the number of milliseconds after which a cached object will be considered stale.

- The expiration time is on per object basis. i.e. Expiration of one cached object does not affect any other cached object.

Background Processing
---------

- You can see the output of parameters and headers being processed in environment specific log file under `log`.

- You can see the queue picking and processing the jobs in `resque:work` output.

- The queue processor does not do much. It simply prints the parameters and headers to log file.


Confusion
---------

Regarding this requirement related to Background queue management:

In case you receive a failure _FROM_ the queue, you should retry
pushing the same message again with an exponential backoff time using
the following formula: (2^retries * 100) milliseconds. (emphasis mine)

The word _FROM_ in this statement is confusing.

I can think of two scenarios with respect to above requirement:

1. When the request arrives at the application from browser and before
redirecting it to the offer url, application will try to enqueue the
parameters and headers to queue for logging. But in case the queue
returns error(possibly timeout) the application will keep trying with
exponentially increasing time to connect to the queue again and again.

If this is the case, the redirect might take a long a time. And the
browser will reject the request with a timeout error. This could be
avoided by limiting the number of retries.

2. When the request arrives at the application from the browser and
parameters and headers are queued for logging successfully. (Assuming
queue is always available. If the queue is not available, this should
be considered an exceptional condition and the issue of queue not
being available should be investigated).

During processing, the worker process faces some error. In this case
the parameters and headers are enqueued again after exponentially
increasing time to process the parameters.

If this is the case, the worker process will blocked till parameters
are processed. This could be avoided by limiting the number of
retries.

Which of the above two scenarios does the problem set talks about?

I have assumed the first scenario with no limit on number of retries.

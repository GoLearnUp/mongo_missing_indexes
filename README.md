
# mongo_missing_indexes

View queries that have missing indexes

## Examples / How-To:

    Mongo::MissingIndexes.enabled = true

    # outside of Rails
    Mongo::MissingIndexes.logger = Logger.new("test.log")

    # inside of Rails, Rails.logger will be used by default

## Running tests

    $ bundle install
    $ bundle exec rspec

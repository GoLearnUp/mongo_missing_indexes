
# mongo_missing_indexes

Want to know what queries are missing an index in a MongoMapper, Mongoid, or general ruby / mongo-backed project?

## Examples:

    require 'mongo/missing_indexes'
    Mongo::MissingIndexes.enabled = true

Outside of Rails, you should assign a logger to log the output:

    Mongo::MissingIndexes.logger = Logger.new("test.log")

Inside of rails, Rails.logger will be used by default (although you can still assign a logger if you want to).

Here's what gets dumped in the log if there is an un-indexed mongo query:

    MONGODB (15.8ms) learnup-development['interview_thank_you_notes'].find({:application_id=>1})
    b843100f-783e-4d85-b298-0c32b44322b8 - unindexed query: interview_thank_you_notes.find({:application_id=>1}, {:transformer=>#<Proc:0x007fd7673c0118@/Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/mongo_mapper-0.12.0/lib/mongo_mapper/plugins/querying.rb:76 (lambda)>})
    b843100f-783e-4d85-b298-0c32b44322b8 -  Query backtrace:
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/mongo_missing_indexes-0.0.1/lib/mongo/missing_indexes.rb:27:in `block in find'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/mongo_missing_indexes-0.0.1/lib/mongo/missing_indexes.rb:26:in `tap'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/mongo_missing_indexes-0.0.1/lib/mongo/missing_indexes.rb:26:in `find'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/plucky-0.5.2/lib/plucky/query.rb:104:in `count'
    b843100f-783e-4d85-b298-0c32b44322b8 -    (irb):2:in `irb_binding'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/workspace.rb:86:in `eval'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/workspace.rb:86:in `evaluate'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/context.rb:379:in `evaluate'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:489:in `block (2 levels) in eval_input'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:623:in `signal_status'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:486:in `block in eval_input'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/ruby-lex.rb:245:in `block (2 levels) in each_top_level_statement'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/ruby-lex.rb:231:in `loop'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/ruby-lex.rb:231:in `block in each_top_level_statement'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/ruby-lex.rb:230:in `catch'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb/ruby-lex.rb:230:in `each_top_level_statement'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:485:in `eval_input'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:395:in `block in start'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:394:in `catch'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/rubies/ruby-2.2.2/lib/ruby/2.2.0/irb.rb:394:in `start'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/railties-3.2.22/lib/rails/commands/console.rb:47:in `start'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/railties-3.2.22/lib/rails/commands/console.rb:8:in `start'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/zeus-0.15.4/lib/zeus/rails.rb:136:in `console'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/zeus-0.15.4/lib/zeus.rb:148:in `block in command'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/zeus-0.15.4/lib/zeus.rb:135:in `fork'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/zeus-0.15.4/lib/zeus.rb:135:in `command'
    b843100f-783e-4d85-b298-0c32b44322b8 -    /Users/smtlaissezfaire/.rvm/gems/ruby-2.2.2@LearnUp/gems/zeus-0.15.4/lib/zeus.rb:50:in `go'
    b843100f-783e-4d85-b298-0c32b44322b8 -    -e:1:in `<main>'

## Install (in Rails):

In your Gemfile:

    gem 'mongo_missing_indexes'

Then run:

    $ bundle install

And add an initializer:

    # config/initializers/missing_indexes.rb

    if Rails.env.development?
      require 'mongo/missing_indexes'
      Mongo::MissingIndexes.enabled = true
    end

## Internal: Running tests

    $ bundle install
    $ bundle exec rspec

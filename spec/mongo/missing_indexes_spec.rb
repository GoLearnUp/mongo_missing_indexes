require 'spec_helper'

describe Mongo::MissingIndexes do
  before do
    Mongo::MissingIndexes.reset!
  end

  it "should be off by default" do
    Mongo::MissingIndexes.should_not be_enabled
  end

  it "should be able to be turned on" do
    Mongo::MissingIndexes.enabled = true
    Mongo::MissingIndexes.should be_enabled

    Mongo::MissingIndexes.enabled = false
    Mongo::MissingIndexes.should_not be_enabled
  end

  it "should not run queries when not enabled" do
    Mongo::MissingIndexes.should_not_receive(:instrument_database)
    @mongo_db['users'].find({ :first_name => "Scott" })
  end

  describe "when enabled" do
    before do
      Mongo::MissingIndexes.enabled = true
      @logger = @test_logger
      Mongo::MissingIndexes.logger = @logger

      @messages_received = []
      @logger.stub(:info) do |message|
        @messages_received << message
      end
    end

    def regexp_escape(str)
      Regexp.new(Regexp.escape(str))
    end

    it "should be enabled" do
      Mongo::MissingIndexes.should be_enabled
    end

    it "should not log the query if there is no data (there is no plan)" do
      @logger.should_not_receive(:info)
      @mongo_db['users'].find({ :first_name => "Scott" })
    end

    it "should log the query if there is data" do
      regex = regexp_escape("unindexed query: users.find({:first_name=>\"Scott\"})")

      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].find({ :first_name => "Scott" })

      @messages_received.should include_matching(regex)
    end

    it "should return the correct result" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })

      res = []

      @mongo_db['users'].find({ :first_name => "Scott" }).each do |x|
        res << x
      end

      res.length.should == 1
      res[0]["first_name"].should == "Scott"
    end

    it "should not log the query if there is an index" do
      @mongo_db['users'].indexes.create_one(first_name: 1)
      @logger.should_not_receive(:info)
      @mongo_db['users'].find({ :first_name => "Scott" })
    end

    it "should log a count query" do
      regexp = regexp_escape("unindexed query: users.find({:first_name=>\"Scott\"})")

      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].find({ :first_name => "Scott" }).count

      @messages_received.should include_matching(regexp)
    end

    it "should log a count query when given directly" do
      regexp = regexp_escape("unindexed query: users.count({:first_name=>\"Scott\"})")

      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].count({ :first_name => "Scott" })

      @messages_received.should include_matching(regexp)
    end

    it "should log an update_one query" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })

      find_query = {
        :first_name => "Scott"
      }
      update_query = {
        '$set' => {
          :last_name => "Taylor"
        }
      }

      regexp = regexp_escape("unindexed query: users.update_one({:first_name=>\"Scott\"}, {\"$set\"=>{:last_name=>\"Taylor\"}})")
      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].update_one(find_query, update_query)

      @messages_received.should include_matching(regexp)
    end

    it "should log an update_many query" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })

      find_query = {
        :first_name => "Scott"
      }
      update_query = {
        '$set' => {
          :last_name => "Taylor"
        }
      }

      regexp = regexp_escape("unindexed query: users.update_many({:first_name=>\"Scott\"}, {\"$set\"=>{:last_name=>\"Taylor\"}})")
      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].update_many(find_query, update_query)

      @messages_received.should include_matching(regexp)
    end

    it "have the backtrace of the query location" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })
      @mongo_db['users'].count({ :first_name => "Scott" })
      @messages_received.should include_matching(/#{__FILE__}:#{__LINE__-1}/)
    end

    it "should work with a cursor (a block)" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })

      block = lambda { |obj| }

      @mongo_db['users'].find({ first_name: "Scott" }, &block)
    end
  end

  describe "logger" do
    it "should use Rails.logger if around" do
      Mongo::MissingIndexes.logger.should == Rails.logger
    end

    it "should use the logger assigned" do
      logger = @test_logger
      Mongo::MissingIndexes.logger = logger
      Mongo::MissingIndexes.logger.should == logger
    end

    it "should raise if no logger and a query provided" do
      @mongo_db['users'].insert_one({ :first_name => "Scott" })

      Mongo::MissingIndexes.logger = nil
      Mongo::MissingIndexes.enabled = true

      lambda {
        @mongo_db['users'].find({ :first_name => "Scott" })
      }.should raise_error
    end
  end
end

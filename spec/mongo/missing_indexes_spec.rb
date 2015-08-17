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
    end

    it "should be enabled" do
      Mongo::MissingIndexes.should be_enabled
    end

    it "should log the query" do
      @logger.should_receive(:info).with("unindexed query: users.find({:first_name=>\"Scott\"})".red)
      @mongo_db['users'].find({ :first_name => "Scott" })
    end

    it "should return the correct result" do
      @mongo_db['users'].insert({ :first_name => "Scott" })

      res = []

      @mongo_db['users'].find({ :first_name => "Scott" }).each do |x|
        res << x
      end

      res.length.should == 1
      res[0]["first_name"].should == "Scott"
    end

    it "should not log the query if there is an index" do
      @mongo_db['users'].create_index(:first_name)
      @logger.should_not_receive(:info)
      @mongo_db['users'].find({ :first_name => "Scott" })
    end

    it "should log a count query" do
      @logger.should_receive(:info).with("unindexed query: users.find({:first_name=>\"Scott\"})".red)
      @mongo_db['users'].find({ :first_name => "Scott" }).count
    end

    it "should log a count query when given directly" do
      @logger.should_receive(:info).with("unindexed query: users.count({:first_name=>\"Scott\"})".red)
      @mongo_db['users'].count({ :first_name => "Scott" })
    end

    it "should log an update query" do
      @mongo_db['users'].insert({ :first_name => "Scott" })

      find_query = {
        :first_name => "Scott"
      }
      update_query = {
        '$set' => {
          :last_name => "Taylor"
        }
      }

      @logger.should_receive(:info).with("unindexed query: users.update({:first_name=>\"Scott\"}, {\"$set\"=>{:last_name=>\"Taylor\"}})".red)
      @mongo_db['users'].update(find_query, update_query)
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
      Mongo::MissingIndexes.logger = nil
      Mongo::MissingIndexes.enabled = true

      lambda {
        @mongo_db['users'].find({ :first_name => "Scott" })
      }.should raise_error
    end
  end
end
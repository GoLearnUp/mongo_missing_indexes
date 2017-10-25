require 'mongo'
require 'logger'
require 'colored'
require 'securerandom'

class Mongo::MissingIndexes
  class << self
    def reset!
      remove_instance_variable(:@logger) if defined?(@logger)
      remove_instance_variable(:@enabled) if defined?(@enabled)
    end

    def enabled=(val)
      @enabled = val

      [
        :find,
        :count,
        :update_one,
        :update_many,
        :delete_one,
        :delete_many,
      ].each do |method_name|
        if @enabled
          Mongo::Collection.class_eval <<-HERE, __FILE__, __LINE__
            unless instance_methods.include?(:#{method_name}_aliased_from_missing_indexes)
              alias_method :#{method_name}_aliased_from_missing_indexes, :#{method_name}

              def #{method_name}(*args, &block)
                #{method_name}_aliased_from_missing_indexes(*args, &block).tap do
                  ::Mongo::MissingIndexes.instrument_database(self, :#{method_name}, *args, &block)
                end
              end
            end
          HERE
        else
          Mongo::Collection.class_eval <<-HERE, __FILE__, __LINE__
            if instance_methods.include?(:#{method_name}_aliased_from_missing_indexes)
              alias_method :#{method_name}, :#{method_name}_aliased_from_missing_indexes
              undef_method :#{method_name}_aliased_from_missing_indexes
            end
          HERE
        end
      end
    end

    def enabled?
      @enabled
    end

    def logger
      defined?(@logger) ?
        @logger :
        @logger ||= defined?(Rails) ? Rails.logger : nil
    end

    attr_writer :logger

    def instrument_database(collection, method_name, *args, &block)
      if !logger
        raise "Must provide a logger"
      end

      if method_name == :update
        explain_method_name = :find
        explain_args = [args[0]]
      else
        return if method_name == :find && args[0] == nil
        explain_method_name = :find
        explain_args = args
      end

      # ignore the block, since collection.find({}, &block) returns nil
      explain = collection.send("#{explain_method_name}_aliased_from_missing_indexes", *explain_args).explain
      non_index_query = false

      if explain['stats']
        if explain['stats']['type'] == "COLLSCAN"
          non_index_query = true
        end
      elsif explain['queryPlanner']
        if explain['queryPlanner']['winningPlan']['stage'] == "COLLSCAN"
          non_index_query = true
        end
      end

      if non_index_query
        query_id = SecureRandom.uuid

        logger.info("mongo_missing_indexes - #{query_id} - unindexed query: #{collection.name}.#{method_name}(#{args.map { |a| a.inspect }.join(", ")})".red)
        logger.info("mongo_missing_indexes - #{query_id} -  Query backtrace:".yellow)
        caller.map(&:to_s).each do |line|
          logger.info("mongo_missing_indexes - #{query_id} -    #{line}".yellow)
        end
      end
    end
  end
end

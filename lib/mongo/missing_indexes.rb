require 'mongo'
require 'logger'
require 'colored'

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
        :update,
      ].each do |method_name|
        if @enabled
          Mongo::Collection.class_eval <<-HERE, __FILE__, __LINE__
            unless instance_methods.include?(:#{method_name}_aliased_from_missing_indexes)
              alias_method :#{method_name}_aliased_from_missing_indexes, :#{method_name}

              def #{method_name}(*args, &block)
                #{method_name}_aliased_from_missing_indexes(*args, &block).tap do
                  Mongo::MissingIndexes.instrument_database(self, :#{method_name}, *args, &block)
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
      if method_name == :update
        explain_method_name = :find
        explain_args = [args[0]]
      else
        return if method_name == :find && args[0] == nil
        explain_method_name = :find
        explain_args = args
      end

      explain = collection.send("#{explain_method_name}_aliased_from_missing_indexes", *explain_args, &block).explain
      non_index_query = false

      if explain['cursor']
        if explain['cursor'] =~ /^BasicCursor/
          non_index_query = true
        end
      elsif explain['executionStats']
        if explain['executionStats']['executionStages']['stage'] != "FETCH"
          non_index_query = true
        end
      end

      if non_index_query
        logger.info("unindexed query: #{collection.name}.#{method_name}(#{args.map { |a| a.inspect }.join(", ")})".red)
      end
    end
  end
end

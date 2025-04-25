require 'semantic_logger'

module Contentful
  class EntryLink
    attr_accessor :id

    def logger
      @logger ||= SemanticLogger[self.class.name]
    end

    def resolve_link
      logger.info("Resolving", id: id)

      entry_data = $entries_data.select { |entry| entry.dig("sys", "id") == id }
      if entry_data.empty?
        logger.error("Could not be resolved", id: id)
        return
      end

      target = target_class.new
      representer_class.new(target).from_hash(entry_data.first)
      target
    end
  end
end

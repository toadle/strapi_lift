module Contentful
  class EntryLink
    attr_accessor :id

    def resolve_link
      entry_data = $entries_data.select { |entry| entry.dig("sys", "id") == id }
      if entry_data.empty?
        $logger.log_error("EntryLink could not be resolved", self.class.name, :error, id)
        return
      end

      target = target_class.new
      representer_class.new(target).from_hash(entry_data.first)
      $logger.log_progress("Processing through link.", self.class.name, :info, id)
      target
    end
  end
end

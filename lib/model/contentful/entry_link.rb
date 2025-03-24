module Contentful
  class EntryLink
    attr_accessor :id

    def resolve_link
      entry_data = $entries_data.select { |entry| entry.dig("sys", "id") == id }
      target = target_class.new
      representer_class.new(target).from_hash(entry_data.first)
      target
    end
  end
end

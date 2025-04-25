require 'semantic_logger'

class EntriesImporter
  def logger
    @logger ||= SemanticLogger[self.class.name]
  end

  def run(entries_data, content_types = {}, ids = [])
    [
      Contentful::Category,
      Contentful::Homepage,
      Contentful::Article
    ].each do |model|
      model_name = model.name.split("::").last.underscore.pluralize
      next if content_types.any? && !content_types.key?(model_name)

      limit = content_types[model_name]
      filtered_entries = entries_data.select do |entry|
        entry.dig("sys", "content_type", "sys", "id") == model.contentful_content_type_id &&
          (ids.empty? || ids.include?(entry.dig("sys", "id")))
      end
      filtered_entries = filtered_entries.first(limit) if limit

      filtered_entries.each_with_index do |entry_data, index|
        logger.info("Processing #{index + 1}/#{filtered_entries.count}", id: entry_data.dig("sys", "id"), model: model_name)

        entry = model.new
        model.contentful_representer_class.new(entry).from_hash(entry_data)
        entry.save!
      end
    end
  end
end

class EntriesImporter
  def run(entries_data)
    [
      Contentful::Category,
      Contentful::Homepage,
      Contentful::Article
    ].each do |model|
      filtered_entries = entries_data.select do |entry|
        entry.dig("sys", "content_type", "sys", "id") == model.contentful_content_type_id
      end

      filtered_entries.each_with_index do |entry_data, index|
        $logger.log_progress("Processing #{index + 1}/#{filtered_entries.count}", model.name, :info, entry_data.dig("sys", "id"))

        entry = model.new
        model.contentful_representer_class.new(entry).from_hash(entry_data)
        entry.save!
      end
    end
  end
end
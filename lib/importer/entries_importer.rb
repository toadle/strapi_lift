class EntriesImporter
  def run(entries_data)
    articles_data = entries_data.select { |entry| entry.dig("sys", "content_type", "sys", "id") == '5duKiNPsR20mgISegMYmwK' }
    articles_data = articles_data.select { |entry| entry.dig("sys", "id") == "4Wc8rbroPCQmw22qEYG8m8" }

    articles_data.each do |article_data|
      article = Contentful::Article.new
      Contentful::ArticleRepresenter.new(article).from_hash(article_data)

      article.save!
    end
  end
end
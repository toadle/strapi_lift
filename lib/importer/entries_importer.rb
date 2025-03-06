class EntriesImporter
  def run(entries_data)
    articles_data = entries_data.select { |entry| entry.dig("sys", "content_type", "sys", "id") == '5duKiNPsR20mgISegMYmwK' }

    articles_data[0..5].each do |article_data|
      article = Contentful::Article.new
      Contentful::ArticleRepresenter.new(article).from_hash(article_data)

      save_article(article)
    end
  end

  private 

  def save_article(article)
    article_data = Strapi::ArticleRepresenter.new(article).to_hash.transform_keys do |key|
      key.to_s.camelize(:lower)
    end

    response = strapi_connection.post("/api/articles", {data: article_data})
    if response.success?
      puts "Article #{article.title} imported successfully."
    else
      puts "Failed to import article #{article.title}: #{response.body}"
    end
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end
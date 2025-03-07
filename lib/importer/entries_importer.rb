class EntriesImporter
  def run(entries_data)
    categories_data = entries_data.select { |entry| entry.dig("sys", "content_type", "sys", "id") == '2vg0mzjdfm4myqIQyqiW0M' }
    articles_data = entries_data.select { |entry| entry.dig("sys", "content_type", "sys", "id") == '5duKiNPsR20mgISegMYmwK' }

    contentful_articles, contentful_categories = create_documents(articles_data, categories_data)
    etablish_connections(contentful_articles, contentful_categories)
  end

  def create_documents(articles_data, categories_data)
    contentful_articles = []
    contentful_categories = []

    categories_data.each do |category_data|
      category = Contentful::Category.new
      Contentful::CategoryRepresenter.new(category).from_hash(category_data)

      save_category(category)
      contentful_categories << category
    end

    articles_data[0..5].each do |article_data|
      article = Contentful::Article.new
      Contentful::ArticleRepresenter.new(article).from_hash(article_data)

      save_article(article)
      contentful_articles << article
    end

    return contentful_articles, contentful_categories
  end

  def etablish_connections(contentful_articles, contentful_categories)
    contentful_articles[0..5].each do |contentful_article|
      update_article_connections(contentful_article, contentful_categories)
    end
  end

  private

  def update_article_connections(contentful_article, contentful_categories)
    connections_data = contentful_article.connections_data(contentful_categories)

    begin
      response = strapi_connection.put("/api/articles/#{contentful_article.strapi_id}", {data: connections_data})
      if response.success?
        puts "Article #{contentful_article.title} connections updated successfully."
      end
    rescue StandardError => e
      puts "Failed to update connections for article #{contentful_article.title}: #{e.message}"
    end
  end

  def save_article(article)
    article_data = Strapi::ArticleRepresenter.new(article).to_hash.transform_keys do |key|
      key.to_s.camelize(:lower)
    end

    begin
      response = strapi_connection.post("/api/articles", {data: article_data})
      if response.success?
        article.strapi_id = response.body.dig("data","documentId")
        puts "Article #{article.title} imported successfully as #{article.strapi_id}."
      end
    rescue StandardError => e
      puts "Failed to import article #{article.title}: #{e.message}"
    end
  end

  def save_category(category)
    category_data = Strapi::CategoryRepresenter.new(category).to_hash.transform_keys do |key|
      key.to_s.camelize(:lower)
    end

    begin
      response = strapi_connection.post("/api/categories", {data: category_data})
      if response.success?
        category.strapi_id = response.body.dig("data","documentId")
        puts "Category #{category.title} imported successfully as #{category.strapi_id}."
      end
    rescue StandardError => e
      puts "Failed to import category #{category.title}: #{e.message}"
    end
  end

  def strapi_connection
    @strapi_connection ||= Strapi::Connection.new
  end
end
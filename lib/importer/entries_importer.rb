class EntriesImporter
  def run(entries_data)
    articles_data = entries_data.select { |entry| entry.dig("sys", "id") == "4Wc8rbroPCQmw22qEYG8m8" }
    homepages_data = entries_data.select { |entry| entry.dig("sys", "id") == "5vXkbOlyUMeS66A8ksqEW4" }

    homepages_data.each do |homepage_data|
      homepage = Contentful::Homepage.new
      Contentful::HomepageRepresenter.new(homepage).from_hash(homepage_data)

      homepage.save!
    end

    # articles_data.each do |article_data|
    #   article = Contentful::Article.new
    #   Contentful::ArticleRepresenter.new(article).from_hash(article_data)

    #   article.save!
    # end
  end
end
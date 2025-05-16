# strapi_lift - Contentful to Strapi Importer

A Ruby-based CLI tool for converting and importing [Contentful](https://www.contentful.com) into [Strapi](https://strapi.io). This tool handles the migration of entries and assets. You'll have to create the needed content types in Strapi beforehand.

## Disclaimer
`strapi_lift` was created to assist with the migration of a Contentful instance to Strapi (for [this website](https://www.hochzeitsplaza.de/)). We successfully migrated around ~11GB of assets and ~2000 entries from Contentful to Strapi with this tool. However, it is not a one-size-fits-all solution. The tool **WILL** require adjustments to fit your specific use case, especially if you have custom content types or complex relationships. You need to know `ruby` and to understand a good portion of the inner workings of this importer in order to use it. This tool was created for a one-time migration, **after all we all hope to always ever use scripts like these once**.

If you need help migrating from Contentful to Strapi, [please reach out to me](https://toadle.me/de). I'm happy to help you with your migration and can offer a more tailored solution for your specific needs.

## Limitations
- Does not handle the creation of **content types** in Strapi. You must create the necessary content types in Strapi before running the import.
- **No support** for cms blocks/rich text fields 
- **No localization** support.

## Features

- Imports Contentful JSON exports into Strapi
- Supports multiple content types and relationships
- Handles asset imports and links
- Also handles assets/images in markdown text fields
- Detailed JSON logging
- Selective content type import
- Asset validation and repair
- Iterative update (you can run the import multiple times to update existing entries)
- Retry logic strapi_lift will retry failed requests up to 3 times before failing

## Prerequisites

- Running strapi instance (target)
- Local Contentful export (JSON) via [Contentful CLI](https://www.contentful.com/developers/docs/tutorials/cli/) including assets
- Content types created in Strapi with `contentful_id` field for each type

## Installation

1. Clone the repository
2. Run `bundle install`
3. Copy `.env.sample` to `.env` and configure:
```
STRAPI_API_TOKEN=your_strapi_token
STRAPI_URL=your_strapi_url
```

## Usage

### Import Content

```bash
bin/strapi_lift import --contentful-content path/to/contentful-export.json --assets-folder path/to/assets
```

Options:
- `--contentful-content`: Path to the Contentful export JSON file (required)
- `--assets-folder`: Path to the folder containing Contentful assets (`images.ctfassets.net`, `videos.ctfassets.net`, ...) (required)
- `--content-types`: Comma-separated list of content types to import with optional limits (e.g., 'articles:10,categories', for testing purposes)
- `--ids`: Comma-separated list of specific entry IDs to import (also for testing)
- `--skip`: Number of entries to skip (default: 0, if the import is interrupted, you can continue from the last entry)

### Reset Content

Removes all imported content from Strapi:

```bash
bin/strapi_lift reset
```

### Fix Assets

Validates and repairs assets, downloading missing files if necessary (because sometimes the Contentful export downloads assets with 0 bytes):

```bash
bin/strapi_lift fix-assets --contentful-content path/to/contentful-export.json --assets-folder path/to/assets
```

## Logging/Debugging

- Review the colorized console output for immediate feedback
- For detailed debugging, examine the `log.jsonl` file which contains structured JSON logs
- You can use `grep` or `jq` to filter the logs for specific information:
  ```bash
  cat log.jsonl | grep error
  # or with jq
  cat log.jsonl | jq 'select(.level == "error")'
  ```

## Adjusting for New Content Types

Strapi Lift was designed to be used for a specific content configuration. To add support for a new content type beyond the default ones (articles, authors, etc.), follow these steps:

### 1. Create a Contentful Model

This model will represent the content during the import process. It is the intermediary between the two representer classes implemented below.

Create a new model class in `lib/model/contentful/`:

```ruby
# lib/model/contentful/product.rb
module Contentful
  class Product
    include StrapiDocumentConnected

    attr_accessor :id, :name, :description, :price

    link_objects \ # for relationships
      source: :offer_links, \ # the name of the attribute that the representer puts the links into
      target: :offers # the name of the attribute in strapi model
      always_resolve: true # during import, the links are resolved only one level deep to avoid circular dependencies. You can set this to true if you want to always resolve this specific link

    link_assets  \ # for assets
      source: :image_links, \ 
      target: :images
    
    api_path "/api/products" # the API path in strapi
    single_content_type! # add this if this is a single content type

    def self.contentful_content_type_id
      "product" # the content type ID in Contentful
    end
  end
end
```

### 2. Create Contentful Representer

Create a representer to parse the Contentful export data in `lib/representer/contentful/`:

```ruby
# lib/representer/contentful/product_representer.rb
module Contentful
  class ProductRepresenter < Representable::Decorator
    include Representable::JSON
    
    nested :fields do # plain attributes in Contentful
      %w(
          name
          description
          price
        ).each do |property_name|
        nested property_name do
          property property_name, as: :de_de # the locale the data is pulled from
        end
      end

      # for relationships, be aware that Contenful only includes linkes to other entries
      # so the data here needs to be a link object
      nested :offers do 
        collection :offer_links, decorator: Contentful::EntryLinkRepresenter, class: Contentful::OfferLink, as: :de_de
      end

      # for assets, be aware that Contentful only includes linkes to other entries
      nested :images do
        collection :image_links, decorator: Contentful::AssetLinkRepresenter, class: Contentful::AssetLink, as: :de_de
      end
    end
  end
end
```
### 3. Create `Link` Classes

Since Contentful only ever include links to other entries, the data is internally read to a link object. This is a simple class that only contains the ID of the linked entry and the class that it is later resolved to. Create them for every link type that you need to read from the export in `lib/model/contentful/`:

```ruby
require_relative 'entry_link'

module Contentful
  class OfferLink < EntryLink
    attr_accessor :id

    def representer_class
      Contentful::OfferRepresenter # when the importer reads the data for this link, what representer to use
    end

    def target_class
      Contentful::Offer # what is the final class of this link
    end
  end
end
```

### 4. Create Strapi Representer

Create a representer for transforming to Strapi format in `lib/representer/strapi/`:

```ruby
# lib/representer/strapi/product_representer.rb
module Strapi
  class ProductRepresenter < Strapi::BaseRepresenter
    property :name
    property :description
    property :price
    property :offers
    property :images
  end
end
```

### 4. Update the Entries Importer

If needed, update the `EntriesImporter` class in `lib/importer/entries_importer.rb` to handle your new content type:

```ruby
# Add to the run method:
def run(entries_data, content_types = {}, ids = [], skip: 0)
    [
      Contentful::Product, # Add your new models here
      Contentful::Offer,
      ...
    ].each do |model|
    ... existing code ...
    end
end
```
You need to add all of you models here that you want to import. The importer only every imports models one level deep. So in order to have working relationships on every entry, you'll need to process each entry once in order to make it work.

### 5. Add Reset Support

Add your new content type to the reset method in `bin/strapi_lift`:

```ruby
# In the reset method
def reset
  ...
  Contentful::Product.reset_strapi!
  Contentful::Offer.reset_strapi!
  ...
end
```

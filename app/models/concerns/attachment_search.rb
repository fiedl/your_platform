concern :AttachmentSearch do
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # http://rny.io/rails/elasticsearch/2013/08/05/full-text-search-for-attachments-with-rails-and-elasticsearch.html
    mapping _source: { excludes: ['file'] } do
      indexes :id, type: 'integer'
      indexes :title
      indexes :filename
      indexes :file_for_elasticsearch, type: 'attachment'
    end
  end

  def file_for_elasticsearch
    file_base64
  end

  def file_base64
    path_to_file = self.file.file.file
    Base64.encode64(open(path_to_file) { |file| file.read })
  end

  def to_indexed_json
    to_json(methods: [:filename, :file_for_elasticsearch])
  end

  class_methods do
    def search(query)
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fields: ['title', 'filename', 'file_for_elasticsearch']
            }
          }
        }
      )
    end
  end
end
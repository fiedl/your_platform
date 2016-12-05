concern :AttachmentSearch do
  included do
    include Elasticsearch::Model
    #include Elasticsearch::Model::Callbacks

    __elasticsearch__.client = Elasticsearch::Client.new host: 'localhost', request_timeout: 5*60

    #after_commit lambda { self.class.delay.index_with_elastic_search(self.id) },  on: :create

    #after_commit lambda { __elasticsearch__.update_document },  on: :update
    #after_commit lambda { __elasticsearch__.delete_document },  on: :destroy

    attr_accessor :highlight

    settings({
      analysis: {
        filter: {
          trigrams_filter: {
            type: 'ngram',
            min_gram: 4,
            max_gram: 4
          }
        },
        analyzer: {
          trigrams: {
            type: 'custom',
            tokenizer: 'standard',
            filter: ['lowercase', 'trigrams_filter']
          }
        }
      }
    }) do
      mappings _source: { excludes: ['file'] } do
        indexes :id, type: 'integer'
        indexes :title, type: 'text', analyzer: 'german', term_vector: 'with_positions_offsets'
        indexes :description, type: 'text', analyzer: 'german', term_vector: 'with_positions_offsets'
        indexes :filename, type: 'text', analyzer: 'german', term_vector: 'with_positions_offsets'
        indexes :file_for_elasticsearch, type: 'attachment', fields: { content: { type: 'text', analyzer: 'german', store: true, term_vector: 'with_positions_offsets' } }
      end
    end
  end

  def file_for_elasticsearch
    file_base64
  end

  def file_base64
    if self.file && self.file.file && self.file.file.file
      path_to_file = self.file.file.file
      Base64.encode64(open(path_to_file) { |file| file.read })
    end
  end

  def as_indexed_json(options = {})
    as_json(methods: [:filename, :file_for_elasticsearch])
  end

  class_methods do
    def search(query)
      #elastic_search_results(query).records.records

      records = []
      elastic_search_results(query).records.each_with_hit do |record, result|
        record.highlight = result.highlight.try(:[], 'file_for_elasticsearch.content').try(:join, " ... ")
        records << record
      end
      return records
    end

    def elastic_search_results(query)
      __elasticsearch__.search({
        query: {
          query_string: {
            query: query,
            default_operator: 'AND',
            fields: ['title', 'filename', 'description', 'file_for_elasticsearch.content'],
            minimum_should_match: "80%"
          }
        },
        highlight: {
          fields: {
            'file_for_elasticsearch.content' => {
              matched_fields: ['title', 'filename', 'description', 'file_for_elasticsearch.content'],
              type: 'fvh'
            }
          },
          require_field_match: false
        }
      })
    end

    def index_with_elastic_search(id)
      self.find(id).__elasticsearch__.index_document
    end
  end
end
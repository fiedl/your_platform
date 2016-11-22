concern :AttachmentSearch do
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings({
      analysis: {
        filter: {
          trigrams_filter: {
            type: 'ngram',
            min_gram: 3,
            max_gram: 3
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
        indexes :title, type: 'text', analyzer: 'trigrams', term_vector: 'with_positions_offsets'
        indexes :filename, type: 'text', analyzer: 'trigrams', term_vector: 'with_positions_offsets'
        indexes :file_for_elasticsearch, type: 'attachment', fields: { content: { type: 'text', store: true, term_vector: 'with_positions_offsets' } }
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
      elastic_search_results(query).records.records
    end

    def elastic_search_results(query)
      __elasticsearch__.search({
        query: {
          query_string: {
            query: query,
            default_operator: 'AND',
            fields: ['title', 'filename', 'file_for_elasticsearch.content']
          }
        },
        highlight: {
          fields: {
            'file_for_elasticsearch.content' => {
              matched_fields: ['title', 'filename', 'file_for_elasticsearch.content'],
              type: 'fvh'
            }
          },
          require_field_match: false
        }
      })
    end
  end
end
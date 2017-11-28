concern :StructureableSearch do

  class_methods do

    def search_by_breadcrumbs(query, options = {})
      # "Erlanger Wingolf > Aktivitas > Burschen" should match "Erlanger Burschen".
      limit = options[:limit]
      count = 0
      base_class = options[:base_class] || Group
      search_attribute = options[:search_attribute] || :name
      query_words = query.split(" ")

      base_class.where(((["(#{search_attribute.to_s} LIKE ?)"] * query_words.count).join(" OR ")), *(query_words.collect { |word| "%#{word}%" })).select do |object|
        if count > limit
          false
        else
          phrase = object.breadcrumb_titles.join(" ")
          if query_words.all? { |word| phrase.downcase.include? word.downcase }
            count += 1
            true
          else
            false
          end
        end
      end
    end

  end

  def breadcrumb_titles
    breadcrumbs.map(&:breadcrumb_title)
  end

end
concern :GroupSearch do
  class_methods do

    def search(query, options = {})
      limit = options[:limit] || 10000
      (search_by_name(query).limit(limit) + search_by_breadcrumbs(query, limit: limit)).uniq.first(limit)
    end

    private

    def search_by_name(query)
      where("name LIKE ?", "%#{query}%")
    end

    def search_by_extensive_name(query)
      where("extensive_name LIKE ?", "%#{query}%")
    end

    def search_by_breadcrumbs(query, options = {})
      # "Erlanger Wingolf > Aktivitas > Burschen" should match "Erlanger Burschen".
      limit = options[:limit]
      count = 0
      query_words = query.split(" ")
      Group.where(((["(name LIKE ?)"] * query_words.count).join(" OR ")), *(query_words.collect { |word| "%#{word}%" })).select do |group|
        if count > limit
          false
        else
          phrase = group.breadcrumb_titles.join(" ")
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
concern :HasPermalinks do

  included do
    has_many :permalinks, as: :reference, dependent: :destroy

    attr_accessible :permalinks_list if defined? attr_accessible
  end

  def permalink_path
    "/#{permalinks.first.path}" if permalinks.any?
  end

  def permalink_paths
    permalinks.collect do |permalink|
      if permalink.host.present?
        "https://#{permalink.host}/#{permalink.path}"
      else
        permalink.path
      end
    end
  end

  def permalinks_list
    permalink_paths.join("\n")
  end

  def permalinks_list=(string)
    paths = string.split(%r{\n|,\s*|\s}).collect { |path| path.gsub("http://", "https://").gsub(/^\/(.*)/, '\1') } - [nil, '']

    new_permalinks = paths.collect do |path|
      if path.include? "https://"
        host = path.gsub("https://", "").split("/").first
        path = path.gsub("https://#{host}/", "")
      end
      Permalink.new path: path, host: host
    end

    self.permalinks = new_permalinks

    return self.permalinks
  end

end
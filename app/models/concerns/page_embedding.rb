# A Page has a database attribute `embedded`, which indicates
# whether the page should be displayed as box on parent pages.
#
concern :PageEmbedding do

  def embedded_pages
    child_pages.where(embedded: true)
  end

end
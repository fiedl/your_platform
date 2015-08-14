module PgSearchConfiguration
  def default_options
    { 
      :using => {
        :trigram => {
          :threshold => 0.1
        }
      }
    }
  end
end
class Term < ActiveRecord::Base
  has_many :term_infos

  enum term: [:winter_term, :summer_term]
end

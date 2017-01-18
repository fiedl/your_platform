concern :CorporationTermInfos do

  included do
    has_many :term_infos, -> { where(type: "TermInfos::ForCorporation") }, foreign_key: 'group_id'
  end

  def generate_term_infos
    years = (Time.zone.now.year - 10)..Time.zone.now.year
    term_types = ["Terms::Winter", "Terms::Summer", "Terms::Year"]
    years.each do |year|
      term_types.each do |type|
        TermInfos::ForCorporation.by_corporation_and_term(self, Term.by_year_and_type(year, type))
      end
    end
    term_infos
  end

end
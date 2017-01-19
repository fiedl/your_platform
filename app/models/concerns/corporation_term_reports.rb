concern :CorporationTermReports do

  included do
    has_many :term_reports, -> { where(type: "TermReports::ForCorporation") }, foreign_key: 'group_id'
  end

  def generate_term_reports
    years = (Time.zone.now.year - 10)..Time.zone.now.year
    term_types = ["Terms::Winter", "Terms::Summer", "Terms::Year"]
    years.each do |year|
      term_types.each do |type|
        TermReports::ForCorporation.by_corporation_and_term(self, Term.by_year_and_type(year, type))
      end
    end
    term_reports
  end

end
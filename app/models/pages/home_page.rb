# This temporary file is for database (STI) compatibility with the upcoming
# homepage module. Delete it when merging sf/wingolf-org.
class Pages::HomePage < Page
  def self.model_name
    Page.model_name
  end
end
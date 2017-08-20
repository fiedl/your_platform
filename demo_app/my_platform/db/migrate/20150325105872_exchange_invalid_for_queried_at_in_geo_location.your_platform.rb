# This migration comes from your_platform (originally 20130315073149)
class ExchangeInvalidForQueriedAtInGeoLocation < ActiveRecord::Migration[4.2]
  def change
    change_table :geo_locations do |t|
      t.remove :invalid
      t.datetime :queried_at
    end
  end
end

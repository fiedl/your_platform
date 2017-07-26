class ExchangeInvalidForQueriedAtInGeoLocation < ActiveRecord::Migration[4.2]
  def change
    change_table :geo_locations do |t|
      t.remove :invalid
      t.datetime :queried_at
    end
  end
end

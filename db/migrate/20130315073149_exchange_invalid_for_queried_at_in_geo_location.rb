class ExchangeInvalidForQueriedAtInGeoLocation < ActiveRecord::Migration
  def change
    change_table :geo_locations do |t|
      t.remove :invalid
      t.datetime :queried_at
    end
  end
end

class AddNameToCamdramVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :camdram_venues, :memoized_name, :string
  end
end

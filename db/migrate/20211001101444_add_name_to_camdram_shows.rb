class AddNameToCamdramShows < ActiveRecord::Migration[6.1]
  def change
    add_column :camdram_shows, :memoized_name, :string
  end
end

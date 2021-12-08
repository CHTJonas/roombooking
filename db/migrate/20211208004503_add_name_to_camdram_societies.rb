class AddNameToCamdramSocieties < ActiveRecord::Migration[6.1]
  def change
    add_column :camdram_societies, :memoized_name, :string
  end
end

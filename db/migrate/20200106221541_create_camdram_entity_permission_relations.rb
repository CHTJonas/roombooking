class CreateCamdramEntityPermissionRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :camdram_shows_users, id: false do |t|
      t.belongs_to :camdram_show, index: true
      t.belongs_to :user, index: true
    end

    create_table :camdram_societies_users, id: false do |t|
      t.belongs_to :camdram_society, index: true
      t.belongs_to :user, index: true
    end
  end
end

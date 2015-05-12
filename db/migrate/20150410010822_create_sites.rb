class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
    	t.string :name
    	t.string :audio
    	t.string :clinic_id, unique: true
    	t.belongs_to :user
    	
      t.timestamps null: false
    end

    add_index :sites, [:clinic_id]
  end
end

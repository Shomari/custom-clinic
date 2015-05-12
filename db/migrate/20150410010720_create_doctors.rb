class CreateDoctors < ActiveRecord::Migration
  def change
    create_table :doctors do |t|
    	t.string :name
    	t.string :speciality
    	t.text :bio
    	t.string :image

    	t.belongs_to :site, null: false
      t.timestamps null: false
    end
    add_foreign_key :doctors, :sites
  end
end

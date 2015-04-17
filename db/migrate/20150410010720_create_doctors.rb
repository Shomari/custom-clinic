class CreateDoctors < ActiveRecord::Migration
  def change
    create_table :doctors do |t|
    	t.string :name
    	t.string :speciality
    	t.text :bio
    	t.string :image

    	t.belongs_to :collection
      t.timestamps null: false
    end
  end
end

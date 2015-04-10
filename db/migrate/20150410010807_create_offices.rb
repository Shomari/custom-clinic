class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
    	t.string :name
    	t.belongs_to :collection

      t.timestamps null: false
    end
  end
end

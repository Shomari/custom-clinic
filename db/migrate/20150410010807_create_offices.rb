class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
    	t.string :name
    	t.string :monday
    	t.string :tuesday
    	t.string :wednesday
    	t.string :thrusday
    	t.string :friday
    	t.string :saturday
    	t.string :sunday

    	t.belongs_to :collection

      t.timestamps null: false
    end
  end
end

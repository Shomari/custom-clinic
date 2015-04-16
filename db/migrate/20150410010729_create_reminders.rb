class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
    	t.integer :position
			t.string :heading
			t.string :message
    	t.belongs_to :collection
    	
      t.timestamps null: false
    end
  end
end

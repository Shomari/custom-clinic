class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
			t.string :info
    	t.belongs_to :collection
    	
      t.timestamps null: false
    end
  end
end

class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
    	t.integer :position
			t.string :heading
			t.text :message

    	t.belongs_to :site    	
      t.timestamps null: false
    end

    add_foreign_key :reminders, :sites
  end
end

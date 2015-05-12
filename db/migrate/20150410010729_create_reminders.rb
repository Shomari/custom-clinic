class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
			t.string :heading
			t.text   :message

    	t.belongs_to :site, null: false    	
      t.timestamps null: false
    end

    add_foreign_key :reminders, :sites
  end
end

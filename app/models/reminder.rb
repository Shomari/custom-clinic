class Reminder < ActiveRecord::Base
	belongs_to :collection
			
	has_many :videos, :as => :recordable
end

class Office < ActiveRecord::Base
	belongs_to :site
	
	has_many :videos, :as => :recordable
end

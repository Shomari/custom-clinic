class Doctor < ActiveRecord::Base
	belongs_to :site
	has_many :videos, :as => :recordable
	
	mount_uploader :image, ImageUploader
end

class Doctor < ActiveRecord::Base
	belongs_to :collection

	has_many :videos, :as => :recordable
	mount_uploader :image, ImageUploader
	process_in_background :image
end

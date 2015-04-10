class Video < ActiveRecord::Base
	belongs_to :recordable, :polymorphic => true
	
	mount_uploader :movie, FilmUploader
end

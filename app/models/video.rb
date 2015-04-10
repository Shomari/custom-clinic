class Video < ActiveRecord::Base
	belongs_to :recordable, :polymorphic => true
	
end

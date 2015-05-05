class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :doctors
	has_many :reminders
	has_many :offices

	accepts_nested_attributes_for :doctors
	accepts_nested_attributes_for :reminders
	accepts_nested_attributes_for :offices

	def check_for_doctor_updates(params)
	doctor_updates = []			
		params[:collection][:doctors_attributes].each_with_index do |doctor, index|
			doc = doctor[1].to_hash
			doc["image"] = doc["image"].original_filename unless doc["image"].blank?
		  doctor_updates << index.to_s unless Doctor.where(doc).present?		  
		end
		doctor_updates
	end

	def check_for_image_updates(params)
		avatars = []
		params[:collection][:doctors_attributes].each_with_index do |doctor, index|
			image_params = params[:collection][:doctors_attributes][index.to_s]["image"]
			doc = doctor[1].to_hash
			doc["image"] = doc["image"].original_filename unless doc["image"].blank?

			if image_params != nil
		  	avatars << image_params.tempfile.path
		  else
		  	avatars << nil
		  end
		end
	end

	def check_for_office_updates(params)
		office = params[:collection][:offices_attributes]["0"].to_hash		
		office["collection_id"] = self.id
		if self.id == nil
			office.values == ["", "", "", "", "", "", "", nil] ? false : true   ### Check for any input when a new office is created
		else
			Office.where(office).present? ? false : true                        ### Check for any changes on an existing office
		end
	end


	### checking reminders for updates
	### only sending updates if the attributes in params are DIFFERENT then what is in the database
	### If they are different, then we know that the user updated them and didn't just leave them the same
	def check_for_reminder_updates(params)
		reminder_updates = []
		params[:collection][:reminders_attributes].each_with_index do |reminder, index|
			remind = reminder[1].to_hash
			remind[:collection_id] = self.id
			if self.id == nil
				reminder_updates << index.to_s unless remind["message"].blank? && remind["heading"].blank?  ### When creating a new collection
			else
				reminder_updates << index.to_s unless Reminder.where(remind).present?                       ### When updating an exisiting collection
			end
		end
		reminder_updates
	end
end


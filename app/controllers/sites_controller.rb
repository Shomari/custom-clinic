class SitesController < ApplicationController
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	before_filter :authenticate_user!

	TRACKS = ["Track 1", "Track 2"]

	def show
		@clinic_id  = session[:clinic_id].to_i

		@site       = Site.find_or_initialize_by(clinic_id: session[:clinic_id].to_i)
		@doctors    = @site.build_doctors
		@offices    = @site.build_offices
		@reminders  = @site.build_reminders

		@tracks     = TRACKS
	end

	def create
		site =  empty_collection ### helper ###
		
		### These methods compare text that is submitted with text stored in the database
		### If text is different (signaling an update), the index of that object is added
		### to updates

		doctor_updates   = site.check_for_doctor_updates(params)
		office_updates   = site.office_hours_updates?(params)
		reminder_updates = site.check_for_reminder_updates(params)

		avatars = []
		params[:site][:doctors_attributes].each_with_index do |doctor, index|
			image_params = params[:site][:doctors_attributes][index.to_s]["image"]
			doc = doctor[1].to_hash
			doc["image"] = doc["image"].original_filename unless doc["image"].blank?
			if image_params != nil
		  	avatars << image_params.tempfile.path
		  else
		  	avatars << nil
		  end
		end
		site = Site.create(site_params)
		site_id = site.id

		DoctorWorker.perform_async(doctor_updates, avatars, params, site_id, current_user)
		OfficeWorker.perform_async(office_updates, params, site_id, current_user)
		ReminderWorker.perform_async(reminder_updates, params, site_id, current_user)
		
		render 'submit'
	end

	def update
		site = Site.find(params[:id])

		doctor_updates   = site.check_for_doctor_updates(params)
		office_updates   = site.office_hours_updates?(params)
		reminder_updates = site.check_for_reminder_updates(params)
		avatars = []
		params[:site][:doctors_attributes].each_with_index do |doctor, index|
			image_params = params[:site][:doctors_attributes][index.to_s]["image"]
			doc = doctor[1].to_hash
			doc["image"] = doc["image"].original_filename unless doc["image"].blank?
			if image_params != nil
		  	avatars << image_params.tempfile.path
		  else
		  	avatars << nil
		  end
		end


		site.update_attributes(site_params)
		site_id = site.id
		DoctorWorker.perform_async(doctor_updates, avatars, params, site_id, current_user.email)
		OfficeWorker.perform_async(office_updates, params, site_id, current_user.email)
		ReminderWorker.perform_async(reminder_updates, params, site_id, current_user.email)
		
		render 'submit'
	end

	private

		def site_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] 
			params.require(:site).permit(:clinic_id, doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

		### can't use this method in the model because I can't pass the carrierwave image
		### as params
		def check_for_image_updates(params)
			avatars = []
			params[:site][:doctors_attributes].each_with_index do |doctor, index|
				image_params = params[:site][:doctors_attributes][index.to_s]["image"]
				doc = doctor[1].to_hash
				doc["image"] = doc["image"].original_filename unless doc["image"].blank?

				if image_params != nil
			  	avatars << image_params.tempfile.path
			  else
			  	avatars << nil
			  end
			end
		end



end
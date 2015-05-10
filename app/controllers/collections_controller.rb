class CollectionsController < ApplicationController
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	before_filter :authenticate_user!

	TRACKS = ["Track 1", "Track 2"]

	def show
		@clinic_id  = session[:clinic_id].to_i

		@collection = Collection.find_or_initialize_by(clinic_id: session[:clinic_id].to_i)
		@doctors    = @collection.build_doctors
		@offices    = @collection.build_offices
		@reminders  = @collection.build_reminders

		@tracks     = TRACKS
	end

	def create
		collection =  empty_collection ### helper ###

		### These methods compare text that is submitted with text stored in the database
		### If text is different (signaling an update), the index of that object is added
		### to updates

		doctor_updates   = collection.check_for_doctor_updates(params)
		office_updates   = collection.check_for_office_updates(params)
		reminder_updates = collection.check_for_reminder_updates(params)

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
		collection = Collection.create(collection_params)
		collection_id = collection.id

		ImageWorker.perform_async(doctor_updates, avatars, office_updates, reminder_updates, params, collection_id)
		
		render :nothing => true
	end

	def update
		collection = Collection.find(params[:id])

		doctor_updates   = collection.check_for_doctor_updates(params)
		office_updates   = collection.check_for_office_updates(params)
		reminder_updates = collection.check_for_reminder_updates(params)
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

		collection.update_attributes(collection_params)
		collection_id = collection.id
		ImageWorker.perform_async(doctor_updates, avatars, office_updates, reminder_updates, params, collection_id)
		
		render :nothing => true
	end

	private

		def collection_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] 
			params.require(:collection).permit(:clinic_id, doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

		### can't use this method in the model because I can't pass the carrierwave image
		### as params
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



end
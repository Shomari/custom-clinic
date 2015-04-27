class CollectionsController < ApplicationController
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	before_filter :authenticate_user!

	TRACKS = ["Track 1", "Track 2"]

	#refactor this, abstract into model class
	def show
		# if no collection, then cna't build last doctor
		# if collection you need a patch route
		@collection = Collection.find_or_initialize_by(user: current_user)
		if @collection.id.nil?
			@collection.offices.build
		else
			@doctor = @collection.doctors.last(5)
			@offices = @collection.offices.last			
		end

		@doctors = @collection.doctors.last(5).to_a
		(5 - @collection.doctors.count).times do
				@doctors << @collection.doctors.build
		end


		@reminders = @collection.reminders.last(10).to_a		
		(10 - @collection.reminders.count).times do
				@reminders << @collection.reminders.build
		end
		# @collection = Collection.new

		@tracks = TRACKS
	end

	def create
		binding.pry
		a= Collection.create(collection_params)
		a.user = current_user
		a.save!
		
		render :nothing => true
	end

	def update
		updates = []
		avatars = []

		### checking doctors for updates
		params[:collection][:doctors_attributes].each_with_index do |doctor, index|
			image_params = params[:collection][:doctors_attributes][index.to_s]["image"]
			
			doc = doctor[1].to_hash
			doc["image"] = doc["image"].original_filename unless doc["image"].blank?
		  updates << index.to_s unless Doctor.where(doc).present?
		  if image_params != nil
		  	avatars << image_params.tempfile.path
		  else
		  	avatars << nil
		  end
		end



		### checking office for updates
		office = params[:collection][:offices_attributes]["0"].to_hash
		Office.where(office).present? ? office_update = false : office_update = true

		### checking reminders for updates
		reminder_updates = []
		params[:collection][:reminders_attributes].each_with_index do |reminder, index|
			remind = reminder[1].to_hash
			reminder_updates << index.to_s unless Reminder.where(remind).present?
		end

		collection = Collection.find(params[:id])
		collection.update_attributes(collection_params)

		ImageWorker.perform_async(updates, avatars, office_update, reminder_updates, params)

		
		render :nothing => true
	end

	private

		def collection_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] 
			params.require(:collection).permit(doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

end
class CollectionsController < ApplicationController
	before_filter :authenticate_user!

	def show
		# if no collection, then cna't build last doctor
		# if collection you need a patch route
		@collection = Collection.find_or_initialize_by(user: current_user)
		if @collection.id.nil?
			@collection.doctors.build
			@collection.offices.build
			10.times do
				@reminders = @collection.reminders.build
			end
		else
			@doctor = @collection.doctors.last
			@offices = @collection.offices.last
			@reminders = @collection.reminders.last(10).to_a
		end
		# @collection = Collection.new
	
	end

	def create
		a= Collection.create(collection_params)
		a.user = current_user
		a.save!
		# a.save!
		# a = Doctor.new(doctor_params)
		render :nothing => true
	end

	def update
		binding.pry
		collection = Collection.find(params[:id])
		collection.update_attributes(collection_params)
		render :nothing => true
	end

	private

		def collection_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saaturday, :sunday]
			params.require(:collection).permit(doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

		def doctor_params
			params.require(:collection).permit(doctor_attributes: [:name, :speciality, :bio])
		end

end
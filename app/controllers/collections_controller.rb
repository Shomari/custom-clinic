class CollectionsController < ApplicationController
	before_filter :authenticate_user!


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
	
	end

	def create
		a= Collection.create(collection_params)
		a.user = current_user
		a.save!
		
		render :nothing => true
	end

	def update
		# data = params[:collection][:doctors_attributes]["0"][:preview]
		# jpeg  = Base64.decode64(data['data:image/jpeg;base64,'.length .. -1])
		# File.open('app/assets/images/test.jpg', 'wb') { |f| f.write(jpeg) }

		collection = Collection.find(params[:id])
		doc = collection.doctors.last

		# MovieWorker.perform_async()

		collection.update_attributes(collection_params)
		render :nothing => true
	end

	private

		def collection_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] 
			params.require(:collection).permit(doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

end
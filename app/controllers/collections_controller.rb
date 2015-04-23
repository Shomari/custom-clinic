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
		# data = params[:collection][:doctors_attributes]["0"][:preview]
		# jpeg  = Base64.decode64(data['data:image/jpeg;base64,'.length .. -1])
		# File.open('app/assets/images/test.jpg', 'wb') { |f| f.write(jpeg) }
		updates = []
		params[:collection][:doctors_attributes].each_with_index do |doctor, index|
			doc = doctor[1].to_hash		  
		  updates << index.to_s unless Doctor.where(doc).present?
		end

		updates.each do |number|
			name = params[:collection][:doctors_attributes][number][:name]
			speciality = params[:collection][:doctors_attributes][number][:speciality]
			bio = params[:collection][:doctors_attributes][number][:bio]
			avatar = params[:collection][:doctors_attributes][number][:image]

			unless avatar.blank?

				avatar_path = avatar.tempfile.path 


				avatar = ImageList.new(avatar_path).last
				avatar = avatar.resize_to_fit(700,500)

				img =  ImageList.new('app/assets/images/CMH_template001.jpg')

				name = Magick::Image.read("caption:#{name}"){
				self.fill = '#D9B2FB'
				self.font = "Helvetica-Bold"
				self.pointsize = 64
				self.size = "600x100"
				self.background_color = "none"
			}.first
		binding.pry

				speciality = Magick::Image.read("caption:#{speciality}"){
				self.fill = '#FFFFFF'
				self.font = "Helvetica"
				self.pointsize = 46
				self.size = "600x50"
				self.background_color = "none"
			}.first
		binding.pry

				bio = Magick::Image.read("caption:#{bio}"){
				self.fill = '#FFFFFF'
				self.font = "Helvetica"
				self.pointsize = 32
				self.size = "600x400"
				self.background_color = "none"
			}.first


		#### comparison plan  ####
		# take params for each doctor and covert to_hash
		# then do Doctor.where("your hash")
		# if it comes back with a match, DON'T do anything, since they are the same
		# if it doesn't find anything, then create the image and the video
		##############

		final = img.composite(avatar, 100, 175, AtopCompositeOp)	
		final = final.composite(name, 550, 175, AtopCompositeOp)
		final = final.composite(speciality, 550, 250, AtopCompositeOp )
		final = final.composite(bio, 550, 315, AtopCompositeOp )

		final.write("tmp/images/yay.jpg")
	end
end

		collection = Collection.find(params[:id])
		# doc = collection.doctors.last
		# MovieWorker.perform_async(name)

		collection.update_attributes(collection_params)
		render :nothing => true
	end

	private

		def collection_params
			days = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] 
			params.require(:collection).permit(doctors_attributes: [ :id, :image, :name, :speciality, :bio], offices_attributes: days, reminders_attributes: [:heading, :message] )
		end

end
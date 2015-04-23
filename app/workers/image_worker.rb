class ImageWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker

	def perform(updates, office_updates, reminder_updates, params)
		binding.pry

		updates.each do |number|
			name = params["collection"]["doctors_attributes"][number]["name"]
			speciality = params["collection"]["doctors_attributes"][number]["speciality"]
			bio = params["collection"]["doctors_attributes"][number]["bio"]
			id = params["collection"]["doctors_attributes"][number]["id"]
			avatar = params["collection"]["doctors_attributes"][number]["image"]

			make_images(name, speciality, bio, id, avatar)			
		end

		make_office_images(params[:collection][:offices_attributes]["0"]) if office_updates == true
			make_reminder_images
	end

	def make_images(name, speciality, bio, id, avatar)
		unless avatar.blank?
			avatar_path = avatar.tempfile.path
			avatar = ImageList.new(avatar_path).last
		else
			avatar = Doctor.find(id).image
		end

		avatar = avatar.resize_to_fit(700,500)

		background =  ImageList.new('app/assets/images/CMH_template001.jpg')

		name_img = create_section_image(name, '#D9B2FB', "Helvetica-Bold", 64, "600x100", "none")
		speciality_img = create_section_image(speciality, '#FFFFFF', "Helvetica", 46, "600x50", "none")
		bio_img = create_section_image(nio, '#FFFFFF', "Helvetica", 32, "600x400", "none")
	end

	def make_office_images(days_hash)
		### pass in arguments to create section image for each day.   
		### Then you will have to change flatten images to take the lots of hashes and parameters in order to flatten them all into the right spot
		monday_img = create_section_image(days_hash["monday"], )
	end		

	def create_section_image(text, fill, font, pointsize, size, background_color)
		Magick::Image.read("caption:#{text}"){
			self.fill = fill
			self.font = font
			self.pointsize = pointsize
			self.size = size
			self.background_color = background_color
		}.first
	end

	def flatten_image(avatar, name_img, speciality_img, bio_img)
		final = background.composite(avatar, 100, 175, AtopCompositeOp)
		final = final.composite(name_img, 550, 175, AtopCompositeOp)
		final = final.composite(speciality_img, 550, 250, AtopCompositeOp )
		final = final.composite(bio_img, 550, 315, AtopCompositeOp )
		final.write("tmp/images/yay.jpg")
	end
end
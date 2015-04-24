class ImageWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker

	def perform(updates, avatars, office_updates, reminder_updates, params)
		updates.each do |number|
			name = params["collection"]["doctors_attributes"][number]["name"]
			speciality = params["collection"]["doctors_attributes"][number]["speciality"]
			bio = params["collection"]["doctors_attributes"][number]["bio"]
			id = params["collection"]["doctors_attributes"][number]["id"]

			avatar = avatars[number.to_i]

			make_doctor_images(name, speciality, bio, id, avatar)			
		end

		office_id = params[:collection][:offices_attributes]["0"]["id"]
		make_office_images(params[:collection][:offices_attributes]["0"], office_id) if office_updates == true
			# make_reminder_images
	end

	def make_doctor_images(name, speciality, bio, id, avatar)
		unless avatar.blank?
			avatar = ImageList.new(avatar).last
		else
			avatar = Doctor.find(id).image
		end

		background =  ImageList.new('app/assets/images/CMH_template001.jpg')
		avatar = avatar.resize_to_fit(700,500)
		name_img = create_section_image(name, '#D9B2FB', "Helvetica-Bold", 64, "600x100", "none")
		speciality_img = create_section_image(speciality, '#FFFFFF', "Helvetica", 46, "600x50", "none")
		bio_img = create_section_image(bio, '#FFFFFF', "Helvetica", 32, "600x400", "none")
		flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, id)
	end

	def make_office_images(days_hash, office_id)
		days_hash.update(days_hash) do |key, value|
			value = create_section_image(value, "#FFFFFF", 'Helvetica-Bold', 60, "500x200", "none")
		end
		background = ImageList.new('app/assets/images/hours-template001.jgp')
		flatten_office_image(background, days_hash, office_id)
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

	def flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, doctor_id)
		final = background.composite(avatar, 100, 175, AtopCompositeOp)
		final = final.composite(name_img, 550, 175, AtopCompositeOp)
		final = final.composite(speciality_img, 550, 250, AtopCompositeOp )
		final = final.composite(bio_img, 550, 315, AtopCompositeOp )
		random = "random number"
		final.write("tmp/images/yay.jpg")
		VideoWorker.perform_async(random, doctor_id)
	end

	def flatten_office_image(background, days_img_hash, office_id)
		final = background.composite(days_img_hash[:monday], 850, 175, AtopCompositeOp )
		final = final.composite(arr[:tuesday], 850, 275, AtopCompositeOp)
		final = final.composite(arr[:wednesday], 850, 375, AtopCompositeOp)
		final = final.composite(arr[:thursday], 850, 475, AtopCompositeOp)
		final = final.composite(arr[:friday], 850, 575, AtopCompositeOp)
		final = final.compositeq(arr[:saturday], 850, 675, AtopCompositeOp)
		final = final.composite(arr[:sunday], 850, 775, AtopCompositeOp)
		final.write("tmp/images/office.jpg"){self.quality = 100}
		VideoWorker.perform_async(random, office_id)
	end
end
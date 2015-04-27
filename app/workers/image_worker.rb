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


		office_id = params["collection"]["offices_attributes"]["0"]["id"]
		make_office_images(params["collection"]["offices_attributes"]["0"], office_id) if office_updates == true
			# make_reminder_images

		reminder_updates.each do |number|
			heading = params["collction"]["reminders_attributes"][number]["heading"]
			message = params["collction"]["reminders_attributes"][number]["message"]
			make_reminder_images(heading, message)
		end
	end

	def make_doctor_images(name, speciality, bio, id, avatar)
		# doctor = Doctor.find(id)
		# if Doc
		# unless avatar.blank?
		# 	binding.pry
		# 	"uploads/doctor/image/id"
		# 	avatar = ImageList.new(avatar).last
		# else
		# 	avatar = Doctor.find(id).image
		# end

		avatar = Doctor.find(id).image

		avatar = Image.read(avatar.file.file).last

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
		background = ImageList.new('app/assets/images/hours_template001.jpg')
		flatten_office_image(background, days_hash, office_id)
	end	

	def make_reminder_images(heading, message)
		background = ImageList.new('app/assets/images/reminder_001.jpg')
		create_section_image
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
		random = SecureRandom.hex
		type = "doctor"
		final.write("tmp/images/#{random}.jpg")
		MovieWorker.perform_async(random, doctor_id, type)
	end

	def flatten_office_image(background, days_img_hash, office_id)
		binding.pry
		final = background.composite(days_img_hash["monday"], 700, 75, AtopCompositeOp )
		final = final.composite(days_img_hash["tuesday"], 700, 150, AtopCompositeOp)
		final = final.composite(days_img_hash["wednesday"], 700, 250, AtopCompositeOp)
		final = final.composite(days_img_hash["thursday"], 700, 325, AtopCompositeOp)
		final = final.composite(days_img_hash["friday"], 700, 450, AtopCompositeOp)
		final = final.composite(days_img_hash["saturday"], 700, 525, AtopCompositeOp)
		final = final.composite(days_img_hash["sunday"], 700, 650, AtopCompositeOp)
		random = SecureRandom.hex
		type = "office"
		final.write("tmp/images/#{random}.jpg"){self.quality = 100}
		MovieWorker.perform_async(random, office_id, type)
	end
end
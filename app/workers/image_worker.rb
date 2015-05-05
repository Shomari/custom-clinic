class ImageWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker

	def perform(updates, avatars, office_updates, reminder_updates, params, collection_id)

		collection = Collection.find(collection_id)
		audio = get_audio_track(params["collection"]["audio"])		
		binding.pry
		updates.each do |number|
			name           = params["collection"]["doctors_attributes"][number]["name"]
			speciality     = params["collection"]["doctors_attributes"][number]["speciality"]
			bio            = params["collection"]["doctors_attributes"][number]["bio"]			
			id             = collection.doctors[number.to_i].id
			avatar         = avatars[number.to_i]

			make_doctor_images(name, speciality, bio, id, avatar, audio)			
		end

		office_id = collection.offices.last.id
		make_office_images(params["collection"]["offices_attributes"]["0"], office_id, audio) if office_updates == true
			# make_reminder_images
		reminder_updates.each do |number|
			heading       = params["collection"]["reminders_attributes"][number]["heading"]
			message       = params["collection"]["reminders_attributes"][number]["message"]
			reminder_id   = collection.reminders[number.to_i].id

			make_reminder_images(heading, message, reminder_id, audio)
		end
	end

		### Once S3 is setup, I should probably make an audio model that has a name and url stored
		### then send the approprate model to the worker
	def get_audio_track(track)
		case track
		when "Track 1"
			"app/assets/images/bensound-funnysong.mp3"
		else
			"app/assets/audio/bensound-acousticbreeze.mp3"
		end
	end

	### Maybe think about returning a hash then calling flatten_doctor_images for the hash instead
	### of passing lots of params
	def make_doctor_images(name, speciality, bio, id, avatar, audio)
		avatar = Doctor.find(id).image
		
		avatar = Image.read(avatar.file.file).last

		background      = ImageList.new('app/assets/images/CMH_template001.jpg')
		avatar          = avatar.resize_to_fit(700,500)
		name_img        = create_section_image(name, '#D9B2FB', "Helvetica-Bold", 64, "600x100")
		speciality_img  = create_section_image(speciality, '#FFFFFF', "Helvetica", 46, "600x50")
		bio_img         = create_section_image(bio, '#FFFFFF', "Helvetica", 32, "600x400")

		flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, id, audio)
	end

	def make_office_images(days_hash, office_id, audio)
		days_hash.update(days_hash) do |key, value|
			value = create_section_image(value, "#FFFFFF", 'Helvetica-Bold', 60, "500x200")
		end
		background = ImageList.new('app/assets/images/hours_template001.jpg')
		flatten_office_image(background, days_hash, office_id, audio)
	end	

	def make_reminder_images(heading, message, reminder_id, audio)
		background  = ImageList.new('app/assets/images/reminder_001.jpg')
		heading_img = create_section_image(heading, '#D9B2FB', "Helvetica-Bold", 64, "1200x100", CenterGravity)
		message_img = create_section_image(message, '#FFFFFF', 'Helvetica-Bold', 50, "1200x400", CenterGravity)
		flatten_reminder_image(background, heading_img, message_img, reminder_id, audio)
	end	

	def create_section_image(text, fill, font, pointsize, size, gravity=nil)
		Magick::Image.read("caption:#{text}"){
			self.fill             = fill
			self.font             = font
			self.pointsize        = pointsize
			self.size             = size
			self.background_color = "none"
			self.gravity          = gravity
		}.first
	end

	def flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, doctor_id, audio)
		final     = background.composite(avatar, 100, 175, AtopCompositeOp)
		final     = final.composite(name_img, 550, 175, AtopCompositeOp)
		final     = final.composite(speciality_img, 550, 250, AtopCompositeOp )
		final     = final.composite(bio_img, 550, 315, AtopCompositeOp )

		random    = SecureRandom.hex
		type      = "doctor"
		final.write("tmp/images/#{random}.jpg")
		MovieWorker.perform_async(random, doctor_id, type, audio)
	end

	def flatten_office_image(background, days_img_hash, office_id, audio)
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
		MovieWorker.perform_async(random, office_id, type, audio)
	end

	def flatten_reminder_image(background, heading_img, message_img, reminder_id, audio)
		final = background.composite(heading_img, 75, 275, AtopCompositeOp)
		final = final.composite(message_img, 75, 275, AtopCompositeOp)
		random = SecureRandom.hex
		type = "reminder"
		final.write("tmp/images/#{random}.jpg"){self.quality = 100}
		MovieWorker.perform_async(random, reminder_id, type, audio)
	end
end
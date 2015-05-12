class ImageWorker
	require_relative '../../config/design'
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(updates, avatars, office_updates, reminder_updates, params, collection_id)

		collection = Collection.find(collection_id)
		audio = get_audio_track(params["collection"]["audio"])

		### number needs to be a string when looking through params  ###
		### however, it needs to be an int when getting ids		       ###
		################################################################

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
		
		### make_reminder_images  ###
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
			"app/assets/audio/audio405188-NORMALIZED.mp3"
		else
			"app/assets/audio/bensound-acousticbreeze.mp3"
		end
	end

	### Maybe think about returning a hash then calling flatten_doctor_images for the hash instead
	### of passing lots of params
	def make_doctor_images(name, speciality, bio, id, avatar, audio)
		avatar = Doctor.find(id).image
		if avatar.file.nil?
			avatar = Image.read('public/transparent.png').last
		else
			avatar = Image.read(avatar.file.file).last
		end
		binding.pry
		background      = ImageList.new('app/assets/images/CMH_template001.jpg')
		avatar          = avatar.resize_to_fit(700,500)
		name_img        = create_section_image(name, NAME_IMG_COLOR, NAME_IMG_FONT, NAME_IMG_FONT_SIZE, NAME_IMG_PICTURE_SIZE)
		speciality_img  = create_section_image(speciality, SPECIALITY_IMG_COLOR, SPECIALITY_IMG_FONT , SPECIALITY_IMG_FONT_SIZE, SPECIALITY_IMG_PICTURE_SIZE )
		bio_img         = create_section_image(bio, BIO_IMG_COLOR , BIO_IMG_FONT, BIO_IMG_FONT_SIZE, BIO_IMG_PICTURE_SIZE )

		flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, id, audio)
	end

	def make_office_images(days_hash, office_id, audio)
		days_hash.update(days_hash) do |key, value|
			value = create_section_image(value, OFFICE_IMAGE_COLOR, OFFICE_IMG_FONT, OFFICE_IMG_FONT_SIZE, OFFICE_IMG_PICTURE_SIZE)
		end
		background = ImageList.new('app/assets/images/hours_template001.jpg')
		flatten_office_image(background, days_hash, office_id, audio)
	end	

	def make_reminder_images(heading, message, reminder_id, audio)
		background  = ImageList.new('app/assets/images/reminder_001.jpg')
		heading_img = create_section_image(heading, HEADING_IMG_COLOR, HEADING_IMG_FONT, HEADING_IMG_FONT_SIZE, HEADING_IMG_PICTURE_SIZE, CenterGravity)
		message_img = create_section_image(message, MESSAGE_IMG_COLOR, MESSAGE_IMG_FONT, MESSAGE_IMG_FONT_SIZE, MESSAGE_IMG_PICTURE_SIZE, CenterGravity)
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
		final     = background.composite(avatar, AVATAR_X , AVATAR_Y, AtopCompositeOp)
		final     = final.composite(name_img, NAME_IMG_X, NAME_IMG_Y, AtopCompositeOp)
		final     = final.composite(speciality_img, SPECIALITY_IMG_X, SPECIALITY_IMG_Y, AtopCompositeOp )
		final     = final.composite(bio_img, BIO_IMG_X, BIO_IMG_Y, AtopCompositeOp )

		random    = SecureRandom.hex
		type      = "doctor"

		final.write("tmp/images/#{random}.jpg")
		MovieWorker.perform_async(random, doctor_id, type, audio)
	end

	def flatten_office_image(background, days_img_hash, office_id, audio)
		final = background.composite(days_img_hash["monday"], X_AXIS, MONDAY_Y, AtopCompositeOp )
		final = final.composite(days_img_hash["tuesday"], X_AXIS, TUESDAY_Y, AtopCompositeOp)
		final = final.composite(days_img_hash["wednesday"], X_AXIS, WEDNEDAY_Y, AtopCompositeOp)
		final = final.composite(days_img_hash["thursday"], X_AXIS, THRUSDAY_Y, AtopCompositeOp)
		final = final.composite(days_img_hash["friday"], X_AXIS, FRIDAY_Y, AtopCompositeOp)
		final = final.composite(days_img_hash["saturday"], X_AXIS, STAURDAY_Y, AtopCompositeOp)
		final = final.composite(days_img_hash["sunday"], X_AXIS, SUNDAY_Y, AtopCompositeOp)

		random = SecureRandom.hex
		type = "office"
		final.write("tmp/images/#{random}.jpg"){self.quality = 100}
		MovieWorker.perform_async(random, office_id, type, audio)
	end

	def flatten_reminder_image(background, heading_img, message_img, reminder_id, audio)
		final = background.composite(heading_img, HEADING_IMG_X, HEADING_IMG_Y, AtopCompositeOp)
		final = final.composite(message_img, MESSAGE_IMG_X, MESSAGE_IMG_Y, AtopCompositeOp)
		random = SecureRandom.hex
		type = "reminder"
		final.write("tmp/images/#{random}.jpg"){self.quality = 100}
		MovieWorker.perform_async(random, reminder_id, type, audio)
	end
end
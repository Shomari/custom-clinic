class DoctorWorker
	require_relative '../../config/design'
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(updates, avatars, params, site_id, user_email)
		site = Site.find(site_id)
		audio = get_audio_track(params["site"]["audio"])
		
		updates.each do |number|
			name           = params["site"]["doctors_attributes"][number]["name"]
			speciality     = params["site"]["doctors_attributes"][number]["speciality"]
			bio            = params["site"]["doctors_attributes"][number]["bio"]			
			id             = site.doctors[number.to_i].id
			avatar         = avatars[number.to_i]

			make_doctor_images(name, speciality, bio, id, avatar, audio, user_email)			
		end
	end

	def get_audio_track(track)
		case track
		when "Track 1"
			"app/assets/audio/audio405188-NORMALIZED.mp3"
		else
			"app/assets/audio/bensound-acousticbreeze.mp3"
		end
	end

	def make_doctor_images(name, speciality, bio, id, avatar, audio, user_email)
		avatar = Doctor.find(id).image
		if avatar.file.nil?
			avatar = Image.read('public/transparent.png').last
		else
			avatar = Image.read(avatar.file.file).last
		end
		background      = ImageList.new('app/assets/images/CMH_template001.jpg')
		avatar          = avatar.resize_to_fit(700,500)
		name_img        = create_section_image(name, NAME_IMG_COLOR, NAME_IMG_FONT, NAME_IMG_FONT_SIZE, NAME_IMG_PICTURE_SIZE)
		speciality_img  = create_section_image(speciality, SPECIALITY_IMG_COLOR, SPECIALITY_IMG_FONT , SPECIALITY_IMG_FONT_SIZE, SPECIALITY_IMG_PICTURE_SIZE )
		bio_img         = create_section_image(bio, BIO_IMG_COLOR , BIO_IMG_FONT, BIO_IMG_FONT_SIZE, BIO_IMG_PICTURE_SIZE )

		flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, id, audio, user_email)
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

	def flatten_doctor_image(background, avatar, name_img, speciality_img, bio_img, doctor_id, audio, user_email)
		final     = background.composite(avatar, AVATAR_X , AVATAR_Y, AtopCompositeOp)
		final     = final.composite(name_img, NAME_IMG_X, NAME_IMG_Y, AtopCompositeOp)
		final     = final.composite(speciality_img, SPECIALITY_IMG_X, SPECIALITY_IMG_Y, AtopCompositeOp )
		final     = final.composite(bio_img, BIO_IMG_X, BIO_IMG_Y, AtopCompositeOp )

		random    = SecureRandom.hex
		type      = "doctor"

		final.write("tmp/images/#{random}.jpg")
		MovieWorker.perform_async(random, doctor_id, type, audio, user_email)
	end

end
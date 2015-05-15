class OfficeWorker
	require_relative '../../config/design'
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(office_updates, params, site_id, user_email)
		site = Site.find(site_id)
		audio = get_audio_track(params["site"]["audio"])

		office_id = site.offices.last.id
		make_office_images(params["site"]["offices_attributes"]["0"], office_id, audio, user_email) if office_updates == true
	end

	def get_audio_track(track)
		case track
		when "Track 1"
			"app/assets/audio/audio405188-NORMALIZED.mp3"
		else
			"app/assets/audio/bensound-acousticbreeze.mp3"
		end
	end

	def make_office_images(days_hash, office_id, audio, user_email)
		days_hash.update(days_hash) do |key, value|
			value = create_section_image(value, OFFICE_IMAGE_COLOR, OFFICE_IMG_FONT, OFFICE_IMG_FONT_SIZE, OFFICE_IMG_PICTURE_SIZE)
		end
		background = ImageList.new('app/assets/images/hours_template001.jpg')
		flatten_office_image(background, days_hash, office_id, audio, user_email)
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

	def flatten_office_image(background, days_img_hash, office_id, audio, user_email)
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
		MovieWorker.perform_async(random, office_id, type, audio, user_email)
	end
end
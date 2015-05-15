class ReminderWorker
	require_relative '../../config/design'
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(reminder_updates, params, site_id, user_email)
		site = Site.find(site_id)
		audio = get_audio_track(params["site"]["audio"])

		reminder_updates.each do |number|
			heading       = params["site"]["reminders_attributes"][number]["heading"]
			message       = params["site"]["reminders_attributes"][number]["message"]
			reminder_id   = site.reminders[number.to_i].id

			make_reminder_images(heading, message, reminder_id, audio)
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

	def make_reminder_images(heading, message, reminder_id, audio, user_email)
		background  = ImageList.new('app/assets/images/reminder_001.jpg')
		heading_img = create_section_image(heading, HEADING_IMG_COLOR, HEADING_IMG_FONT, HEADING_IMG_FONT_SIZE, HEADING_IMG_PICTURE_SIZE, CenterGravity)
		message_img = create_section_image(message, MESSAGE_IMG_COLOR, MESSAGE_IMG_FONT, MESSAGE_IMG_FONT_SIZE, MESSAGE_IMG_PICTURE_SIZE, CenterGravity)
		flatten_reminder_image(background, heading_img, message_img, reminder_id, audio, user_email)
	end	

	def flatten_reminder_image(background, heading_img, message_img, reminder_id, audio, user_email)
		final = background.composite(heading_img, HEADING_IMG_X, HEADING_IMG_Y, AtopCompositeOp)
		final = final.composite(message_img, MESSAGE_IMG_X, MESSAGE_IMG_Y, AtopCompositeOp)
		random = SecureRandom.hex
		type = "reminder"
		final.write("tmp/images/#{random}.jpg"){self.quality = 100}
		MovieWorker.perform_async(random, reminder_id, type, audio, user_email)
	end
end
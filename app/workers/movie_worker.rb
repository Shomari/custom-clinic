class MovieWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker

	

	def perform(random, id, type)
		
		# source = MiniMagick::Image.open('app/assets/images/test.jpg')
		video = Video.new
		output = "app/assets/video_temp/#{random}.mp4"
		`ffmpeg -framerate 1/8 -i tmp/images/#{random}.jpg -i app/assets/images/bensound-funnysong.mp3 -shortest -map 0:0 -map 1:0 -c:v libx264 -pix_fmt yuv420p #{output}`

		File.open(output) do |f|
			video.movie = f
		end

		save_video(id, type)		
		VideoMailer.sample_email(video.movie).deliver
	end

	def save_video(id, type)
		case type
		when "doctor"
			doctor = Doctor.find(id)
			Video.create(recordable: doctor)
		when "office"
			office = Office.find(id)
			Video.create(recordable: office)
		when "reminder"
			reminder = Reminder.find(id)
			Video.create(recordable: reminder)
		end
	end	
end
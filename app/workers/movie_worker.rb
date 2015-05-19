class MovieWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false
	

	def perform(random, model_id, type, audio, user)
		
		video = Video.new
		output = "app/assets/video_temp/#{random}.mp4"

		### command-line code to covert images to mp4 using FFmpeg
		`ffmpeg -framerate 1/8 -i tmp/images/#{random}.jpg -i #{audio} -shortest -map 0:0 -map 1:0 -profile:v baseline -c:v libx264 -pix_fmt yuv420p #{output}`

		File.open(output) do |f|
			video.movie = f
		end
		clinic_id = save_video(model_id, type)	
		VideoMailer.sample_email(video.movie, user).deliver!

		File.delete("tmp/images/#{random}.jpg")
		File.delete(output)

		#get folder containing temporary video storage.
		folder=File.dirname(video.movie.file.file)
		FileUtils.rm_r(folder)
	end


	### Saving video to the database and returning the clinic id to make a SF case with it
	def save_video(id, type)
		case type
		when "doctor"
			doctor = Doctor.find(id)
			Video.create(recordable: doctor)
			doctor.site.clinic_id
		when "office"
			office = Office.find(id)
			Video.create(recordable: office)
			office.site.clinic_id
		when "reminder"
			reminder = Reminder.find(id)
			Video.create(recordable: reminder)
			reminder.site.clinic_id
		end
	end	
end
class MovieWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker
	sidekiq_options :retry => false
	

	def perform(random, id, type, audio)
		
		video = Video.new
		output = "app/assets/video_temp/#{random}.mp4"

		### command-line code to covert images to mp4 using FFmpeg
		`ffmpeg -framerate 1/8 -i tmp/images/#{random}.jpg -i #{audio} -shortest -map 0:0 -map 1:0 -profile:v baseline -c:v libx264 -pix_fmt yuv420p #{output}`

		File.open(output) do |f|
			video.movie = f
		end
		bindig.pry
		clinic_id = save_video(id, type)	
		raise "hello lee's right"	
		VideoMailer.sample_email(video.movie).deliver

		### Delete temporary images and video after they are no longer needed
		###  This should get moved down after S3 upload has finished.
		File.delete("tmp/images/#{random}.jpg")
		File.delete(output)

		#get folder containing temporary video storage.
		folder=File.dirname(video.movie.file.file)
		FileUtils.rm_r(folder)
		


		# s3_upload(output, clinic_id)
	end

	def s3_upload(file_path, clinic_id)
		connection = Fog::Storage.new({
			:provider               => 'AWS',
			:aws_access_key_id      =>  ENV["aws_access_key"],
			:aws_secret_access_key  =>  ENV["aws_secret_access_key"],
			:region                 =>  'us-west-2'
			})

		bucket = connection.directories.get('customclinic')

		file = bucket.files.create(
			:key      => "#{file_path}",
			:body     => File.open(file_path),
			:public   => true
			)

		url = file.url(0)[/.+?(?=\?)/]
		# File.delete(file_path)

		SalesforceWorker.perform_async(clinic_id, url)
	end

	### Saving video to the database and returning the clinic id to make a SF case with it
	def save_video(id, type)
		case type
		when "doctor"
			doctor = Doctor.find(id)
			Video.create(recordable: doctor)
			doctor.collection.clinic_id
		when "office"
			office = Office.find(id)
			Video.create(recordable: office)
			office.collection.clinic_id
		when "reminder"
			reminder = Reminder.find(id)
			Video.create(recordable: reminder)
			reminder.collection.clinic_id
		end
	end	
end
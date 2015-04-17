class MovieWorker
	include Sidekiq::Worker

	def perform()
		source = MiniMagick::Image.open('app/assets/images/test.jpg')
		video = Video.new
		filename = "app/assets/video_tem4p/movie.mp4"
		`ffmpeg -framerate 1/5 -i "#{source.path}" -i app/assets/images/bensound-funnysong.mp3 -shortest -c:v libx264 -map 0:0 -map 1:0 -pix_fmt yuv420p app/assets/video_temp/movie.mp4`


		File.open("app/assets/video_temp/movie.mp4") do |f|
			video.movie = f
		end

		video.save!
		binding.pry
		VideoMailer.sample_email(video.movie).deliver
	end
end
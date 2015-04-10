class CollectionController < ApplicationController
	before_filter :authenticate_user!

	def show
		@collection = Collection.new
		@doctor = Doctor.new
	end

	def create
		source = MiniMagick::Image.open('app/assets/images/background001.jpg')
		video = Video.new
		filename = "app/assets/video_tem4p/movie.mp4"
		`ffmpeg -framerate 1/5 -i "#{source.path}" -c:v libx264 -pix_fmt yuv420p app/assets/video_temp/movie.mp4`
		
		File.open("app/assets/video_temp/movie.mp4") do |f|
			video.movie = f
		end

		video.save!
		binding.pry
		VideoMailer.sample_email(video.movie).deliver
		 
		render :nothing => true
	end
end
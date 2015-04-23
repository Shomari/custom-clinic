class MovieWorker
	require 'rvg/rvg'
	require 'RMagick'
	include Magick
	include Sidekiq::Worker

	

	def perform(name)
		image_list(name)
		# source = MiniMagick::Image.open('app/assets/images/test.jpg')
		# video = Video.new
		# filename = "app/assets/video_tem4p/movie.mp4"
		# `ffmpeg -framerate 1/5 -i "#{source.path}" -i app/assets/images/bensound-funnysong.mp3 -shortest -c:v libx264 -map 0:0 -map 1:0 -pix_fmt yuv420p app/assets/video_temp/movie.mp4`


		# File.open("app/assets/video_temp/movie.mp4") do |f|
		# 	video.movie = f
		# end

		# video.save!
		# binding.pry
		# VideoMailer.sample_email(video.movie).deliver
	end

	def image_list(name)
		img =  ImageList.new('app/assets/images/CMH_template001.jpg')
		doc = Magick::Image.read("caption:#{name}"){
		self.fill = '#D9B2FB'
		self.font = "Helvetica-Bold"
		self.pointsize = 64
		self.size = "600x100"
		self.background_color = "none"
	}.first

	final = img.composite(doc, 700, 300, AtopCompositeOp)
	binding.pry

	end
end
class MovieWorker
	include Sidekiq::Worker

	def perform()
		source = Magick::Image.read(image_path('background001.jpg'))
		binding.pry
	end
end
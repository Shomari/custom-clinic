class MovieWorker
	include Sidekiq::Worker

	def perform()
		source= MiniMagick::Image.open('background001.jpg')

		binding.pry
	end
end
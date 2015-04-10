class CollectionController < ApplicationController
	before_filter :authenticate_user!

	def show
		@collection = Collection.new
		@doctor = Doctor.new
	end

	def create
		MovieWorker.perform_async()
	end
end
class AdminController < ApplicationController 
	before_filter :authenticate_user!
	rescue_from Faraday::ResourceNotFound, :with => :clinic_not_found

	def index
	end

	### checks salesforce to make sure client id enter exists
	def verify
		client = get_salesforce_client
		clinic = client.find('Account', params[:clinic_id], 'CMHID__c' )		
		session[:clinic_id] = clinic.CMHID__c
		session[:clinic_name] = "Fake clinic name"
		redirect_to show_site_path
	end

	private

	def user_params
		params.require(:user).permit(:email, :password)
	end

	def clinic_not_found
		flash[:notice] = "Can't find clinic with that id"
		redirect_to :back
	end

end
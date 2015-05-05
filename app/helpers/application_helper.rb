module ApplicationHelper

	def get_salesforce_client
		client = Restforce.new :host => 'test.salesforce.com',
			:username       => ENV["sf_username"],
		  :password       => ENV["sf_password"],
		  :security_token => ENV["sf_security_token"],
		  :client_id      => ENV["sf_client_id"],
		  :client_secret  => ENV["sf_client_secret"]

		  client
	end

	def empty_collection
		empty_hash = 
		  {"audio"=>"Track 1",
		   "doctors_attributes"=>
		    {"0"=>{"name"=>"", "speciality"=>"", "bio"=>""},
		     "1"=>{"name"=>"", "speciality"=>"", "bio"=>""},
		     "2"=>{"name"=>"", "speciality"=>"", "bio"=>""},
		     "3"=>{"name"=>"", "speciality"=>"", "bio"=>""},
		     "4"=>{"name"=>"", "speciality"=>"", "bio"=>""}},
		   "offices_attributes"=>{"0"=>{"monday"=>"", "tuesday"=>"", "wednesday"=>"", "thursday"=>"", "friday"=>"", "saturday"=>"", "sunday"=>""}},
		   "reminders_attributes"=>
		    {"0"=>{"heading"=>"", "message"=>""},
		     "1"=>{"heading"=>"", "message"=>""},
		     "2"=>{"heading"=>"", "message"=>""},
		     "3"=>{"heading"=>"", "message"=>""},
		     "4"=>{"heading"=>"", "message"=>""},
		     "5"=>{"heading"=>"", "message"=>""},
		     "6"=>{"heading"=>"", "message"=>""},
		     "7"=>{"heading"=>"", "message"=>""},
		     "8"=>{"heading"=>"", "message"=>""},
		     "9"=>{"heading"=>"", "message"=>""}}}

		 Collection.new(empty_hash)
	end
end

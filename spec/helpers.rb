module Helpers

	def params
		{"collection"=>
	  {"clinic_id"=>"69",
	   "audio"=>"Track 1",
	   "doctors_attributes"=>
	    {"0"=>
	      {
	       "name"=>"workig",
	       "speciality"=>"yes",
	       "bio"=>"This is for spec",
	       "id"=>"1"},
	     "1"=>{"name"=>"doc", "speciality"=>"winq", "bio"=>"hi", "id"=>"2"},
	     "2"=>{"name"=>"", "speciality"=>"", "bio"=>"", "id"=>"3"},
	     "3"=>{"name"=>"", "speciality"=>"", "bio"=>"", "id"=>"4"},
	     "4"=>{"name"=>"", "speciality"=>"", "bio"=>"", "id"=>"5"}},
	   "offices_attributes"=>
	    {"0"=>
	      {"monday"=>"10 AM - 5PM",
	       "tuesday"=>"10 AM - 5PM",
	       "wednesday"=>"",
	       "thursday"=>"",
	       "friday"=>"",
	       "saturday"=>"CLOSED",
	       "sunday"=>"",
	       "id"=>"5"}},
	   "reminders_attributes"=>
	    {"0"=>{"heading"=>"RSPEC", "message"=>"TEST PARAMS", "id"=>"41"},
	     "1"=>{"heading"=>"Rspec 2", "message"=>"spec 2", "id"=>"42"},
	     "2"=>{"heading"=>"", "message"=>"", "id"=>"43"},
	     "3"=>{"heading"=>"", "message"=>"", "id"=>"44"},
	     "4"=>{"heading"=>"", "message"=>"", "id"=>"45"},
	     "5"=>{"heading"=>"", "message"=>"", "id"=>"46"},
	     "6"=>{"heading"=>"", "message"=>"", "id"=>"47"},
	     "7"=>{"heading"=>"", "message"=>"", "id"=>"48"},
	     "8"=>{"heading"=>"", "message"=>"", "id"=>"49"},
	     "9"=>{"heading"=>"", "message"=>"", "id"=>"50"}}},
	 "commit"=>"Submit",
	 "controller"=>"collections",
	 "action"=>"update",
	 "id"=>"1"}
	end

	def blank_params
		{"collection"=>
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
		     "9"=>{"heading"=>"", "message"=>""}}}}
	end
end
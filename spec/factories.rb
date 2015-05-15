FactoryGirl.define do
	factory :site do
		clinic_id '69'
	end

	# Create doctors with blank attributes to compare to the attributes of the parameters sent in
	factory :doctor do
		site
		name ""
		speciality ""
		bio ""
	end

	factory :office do
		site
		id 5 # this is the office id that is used in the test params created in the helper
	end

	factory :reminder do
		site
		heading ""
		message ""		
	end

	factory :site_with_associations, :parent => :site do |site|
		doctors   {build_list :doctor, 5}
		offices   {build_list :office, 1}
		reminders {build_list :reminder, 10}
	end
end
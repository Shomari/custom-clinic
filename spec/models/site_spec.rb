require 'rails_helper'
require_relative '../helpers'

RSpec.configure do |config|
	config.include Helpers
	config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RSpec.describe Site, type: :model do  

  let!(:param){params}
  let!(:site_with_associations){create(:site_with_associations)}
  let!(:site_no_associations){create(:site)}

  ### Association tests ###
  it {should belong_to(:user)}

	it {should have_many(:doctors)}	  
	it {should have_many(:reminders)}	  
	it {should have_many(:offices)}	  

	it {should accept_nested_attributes_for(:doctors)}
	it {should accept_nested_attributes_for(:reminders)}
	it {should accept_nested_attributes_for(:offices)}


	describe 'check_for_doctor_updates' do

		it 'should return index of updated doctors' do
			5.times do |i| 
				create(:doctor, id: i+1, site: site_no_associations) 
			end
			expect(site_no_associations.check_for_doctor_updates(params)).to eq(["0","1"])  ### Fake params had Doctors 1 and 2 updated
		end
	end

	describe 'check_for_reminder_updates' do
		it 'should return index of updated reminders' do
			10.times do |i| 
				create(:reminder, id: i+1, site: site_no_associations) 
			end
			expect(site_no_associations.check_for_reminder_updates(params)).to eq(["0","1"])  ### Fake params had reminders 1 and 2 updated
		end
	end

	describe 'office_hours_updates?' do
		it 'should return true if no office already exists and office params are not blank' do
			expect(site_with_associations.office_hours_updates?(params)).to eq(true)
		end

	 it 'should return false if no office already exists and office params are blank' do
		  site = Site.new
		  expect(site.office_hours_updates?(blank_params)).to eq(false)
	 end

	 it 'should return true if params have different values than existing office' do
	 		expect(site_with_associations.office_hours_updates?(blank_params)).to eq(true)
	end
end



	context 'building_models' do

		describe 'build_doctors' do
			it 'should build 5 doctors if no doctors exist' do
				empty_site = Site.new
				empty_site.build_doctors
				expect(empty_site.doctors.length).to eq(5)
			end

			it 'should not build any doctors if site already has 5' do
				site_with_associations.build_doctors   # Factory Girl already sets this up with 5 doctors that are associated.
				expect(site_with_associations.doctors.length).to eq(5)
			end
		end

		describe 'build_reminders' do 
			it 'should build 10 reminders if no reminders exist' do 
				empty_site = Site.new
				empty_site.build_reminders
				expect(empty_site.reminders.length).to eq(10)
			end

			it 'should not build any reminders if site already has 10' do
				site_with_associations.build_reminders   # Factory Girl already sets this up with 10 reminders that are associated.
				expect(site_with_associations.reminders.length).to eq(10)
			end
		end

		describe 'build_offices' do
			it 'builds a new office if no office exists' do
				empty_site = Site.new
				empty_site.build_offices
				expect(empty_site.offices.length).to eq(1)
			end

			it 'should get the office if one exsits' do
				expect(site_with_associations.build_offices).to eq(Office.last)
			end
		end
	end

	 # context 'when updating an existing collection' do
	 # 	it 'should return index of updated doctors' do

	 # 		doc1.name = "Test Doctor"
	 # 		expect(test_collection.check_for_doctor_updates(params)).to eq(["0"])
	 # 	end
	 # end

end



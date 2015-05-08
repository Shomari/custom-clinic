require 'rails_helper'
require_relative '../helpers'

RSpec.configure do |c|
	c.include Helpers
	c.include FactoryGirl::Syntax::Methods
end

RSpec.describe Collection, type: :model do  

  let(:param){params}
  let(:test_collection){create(:collection)}  
	let!(:doc1){Doctor.create!(id: 1, name: "", speciality: "", bio: "")}	  	
	let!(:doc2){Doctor.create!(id: 2, name: "", speciality: "", bio: "")}	  	
	let!(:doc3){Doctor.create!(id: 3, name: "", speciality: "", bio: "")}	  	
	let!(:doc4){Doctor.create!(id: 4, name: "", speciality: "", bio: "")}	  	
	let!(:doc5){Doctor.create!(id: 5, name: "", speciality: "", bio: "")}

	it {should belong_to(:user)}

	it {should have_many(:doctors)}	  
	it {should have_many(:reminders)}	  
	it {should have_many(:offices)}	  

	it {should accept_nested_attributes_for(:doctors)}
	it {should accept_nested_attributes_for(:reminders)}
	it {should accept_nested_attributes_for(:offices)}


	describe '#check_for_doctor_updates' do
	  it 'should return index of updated doctors' do
	  	expect(test_collection.check_for_doctor_updates(params)).to eq(["0","1"])  ### Fake params had Doctors 1 and 2 updated
	 end
	end

	describe '#check_for_office_updates' do

	 it 'should return true if no office already exists and office params are not blank' do
	 	expect(test_collection.check_for_office_updates(params)).to eq(true)
	 end

	 it 'should return false if no office already exists and office params are blank' do
	 	collection = Collection.new
	 	expect(collection.check_for_office_updates(blank_params)).to eq(false)
	 end

	 it 'should return true if params have different values than existing office' do
	 	expect(test_collection.check_for_office_updates(blank_params)).to eq(true)
	end

end

	 # context 'when updating an existing collection' do
	 # 	it 'should return index of updated doctors' do

	 # 		doc1.name = "Test Doctor"
	 # 		expect(test_collection.check_for_doctor_updates(params)).to eq(["0"])
	 # 	end
	 # end

end



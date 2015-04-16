class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :doctors
	has_many :reminders
	has_many :offices

	accepts_nested_attributes_for :doctors
	accepts_nested_attributes_for :reminders
	accepts_nested_attributes_for :offices
end

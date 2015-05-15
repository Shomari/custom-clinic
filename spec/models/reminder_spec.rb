require 'rails_helper'

RSpec.describe Reminder, type: :model do
	it {should belong_to(:site)}
end

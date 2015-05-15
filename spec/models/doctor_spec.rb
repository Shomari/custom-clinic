require 'rails_helper'

RSpec.describe Doctor, type: :model do
	it {should belong_to(:site)}
end

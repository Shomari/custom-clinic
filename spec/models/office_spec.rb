require 'rails_helper'

RSpec.describe Office, type: :model do
	it {should belong_to(:site)}
end

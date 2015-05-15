require 'rails_helper'

RSpec.describe Video, type: :model do
	it {should belong_to(:recordable)}
end

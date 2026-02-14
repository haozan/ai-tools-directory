require 'rails_helper'

RSpec.describe "Categories", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { last_or_create(:user) }
  # before { sign_in_as(user) }

  describe "GET /categories/:id" do
    let(:category_record) { create(:category) }

    it "returns http success" do
      get category_path(category_record)
      expect(response).to be_success_with_view_check('show')
    end
  end
end

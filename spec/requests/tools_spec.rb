require 'rails_helper'

RSpec.describe "Tools", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { last_or_create(:user) }
  # before { sign_in_as(user) }

  describe "GET /tools" do
    it "returns http success" do
      get tools_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /tools/:id" do
    let(:tool_record) { create(:tool) }

    it "returns http success" do
      get tool_path(tool_record)
      expect(response).to be_success_with_view_check('show')
    end
  end
end

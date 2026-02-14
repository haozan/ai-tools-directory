require 'rails_helper'

RSpec.describe "Admin::Tools", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/tools" do
    it "returns http success" do
      get admin_tools_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end

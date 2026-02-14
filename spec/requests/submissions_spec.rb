require 'rails_helper'

RSpec.describe "Submissions", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { last_or_create(:user) }
  # before { sign_in_as(user) }

  describe "GET /submissions/new" do
    it "returns http success" do
      get new_submission_path
      expect(response).to be_success_with_view_check('new')
    end
  end

  describe "POST /submissions" do
    it "creates a new submission" do
      submission_params = {
        name: "Test AI Tool",
        website_url: "https://example.com",
        short_description: "A test AI tool",
        long_description: "This is a test AI tool for testing purposes",
        pricing_type: "Free",
        logo_url: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400&auto=format&fit=crop"
      }
      post submissions_path, params: { tool: submission_params }
      expect(response).to redirect_to(tools_path)
    end
  end
end

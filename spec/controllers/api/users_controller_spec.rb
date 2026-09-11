require "rails_helper"

describe Api::UsersController do
  describe "POST create" do
    it "registers a new user" do
      post :create, params: {
        user: {
          username: "Manuela",
          email: "manuela@consul.dev",
          password: "Judgmentday1",
          password_confirmation: "Judgmentday1",
          terms_of_service: "1"
        }
      }

      expect(response).to have_http_status(:created)
      expect(User.find_by(email: "manuela@consul.dev")).to be_present
    end

    it "requires accepting the terms of service" do
      post :create, params: {
        user: {
          username: "Manuela",
          email: "manuela@consul.dev",
          password: "Judgmentday1",
          password_confirmation: "Judgmentday1"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(User.find_by(email: "manuela@consul.dev")).to be(nil)
    end
  end
end

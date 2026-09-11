require "rails_helper"

describe "API sessions" do
  describe "POST /api/session" do
    it "returns a token for valid credentials" do
      user = create(:user)

      post "/api/session", params: { login: user.email, password: "Judgmentday1" }

      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to be_present
    end

    it "accepts login by username" do
      user = create(:user)

      post "/api/session", params: { login: user.username, password: "Judgmentday1" }

      expect(response).to have_http_status(:created)
    end

    it "returns a generic error for an invalid password" do
      user = create(:user)

      post "/api/session", params: { login: user.email, password: "wrong password" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_blank
    end

    it "returns a generic error for a non-existent login" do
      post "/api/session", params: { login: "nobody@consul.dev", password: "wrong password" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "locks the account after too many failed attempts, same as the web login" do
      user = create(:user)

      (User.maximum_attempts + 1).times do
        post "/api/session", params: { login: user.email, password: "wrong password" }
      end

      expect(user.reload).to be_access_locked
    end
  end

  describe "DELETE /api/session" do
    it "revokes the token so it can no longer be used to authenticate" do
      user = create(:user)
      proposal = create(:proposal)
      post "/api/session", params: { login: user.email, password: "Judgmentday1" }
      token = response.headers["Authorization"]

      delete "/api/session", headers: { "Authorization" => token }
      expect(response).to have_http_status(:no_content)

      post "/api/proposals/#{proposal.id}/vote", headers: { "Authorization" => token }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

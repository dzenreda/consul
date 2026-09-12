require "rails_helper"

describe Api::ProposalsController do
  describe "GET index" do
    it "does not require authentication" do
      create(:proposal)

      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET show" do
    it "does not require authentication" do
      proposal = create(:proposal)

      get :show, params: { id: proposal.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST create" do
    it "requires authentication" do
      post :create, params: { proposal: { title: "A new proposal" }}

      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a proposal for the current user" do
      user = create(:user, :level_two)
      sign_in(user)

      post :create, params: {
        proposal: {
          title: "A new proposal",
          summary: "Proposal summary",
          terms_of_service: "1"
        }
      }

      expect(response).to have_http_status(:created)
      expect(Proposal.last.author).to eq user
    end

    it "publishes the proposal" do
      user = create(:user, :level_two)
      sign_in(user)

      post :create, params: {
        proposal: {
          title: "A new proposal",
          summary: "Proposal summary",
          terms_of_service: "1"
        }
      }

      expect(Proposal.last).to be_published
    end
  end

  describe "PATCH update" do
    it "does not delete other proposal's map location" do
      proposal = create(:proposal)
      other_proposal = create(:proposal, :with_map_location)
      sign_in(proposal.author)

      patch :update, params: {
        id: proposal.id,
        proposal: {
          map_location_attributes: { id: other_proposal.map_location.id },
          responsible_name: "Skinny Fingers"
        }
      }

      expect(proposal.reload.responsible_name).to eq "Skinny Fingers"
      expect(other_proposal.reload.map_location).not_to be nil
    end
  end

  describe "POST vote" do
    it "requires authentication" do
      proposal = create(:proposal)

      post :vote, params: { id: proposal.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it "registers a yes vote and follows the proposal" do
      user = create(:user, :level_two)
      proposal = create(:proposal)
      sign_in(user)

      post :vote, params: { id: proposal.id }

      expect(response).to have_http_status(:ok)
      expect(proposal.reload.total_votes).to eq 1
      expect(Follow.find_by(user: user, followable: proposal)).to be_present
    end
  end
end

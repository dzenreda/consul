require "rails_helper"

describe Api::CommentsController do
  describe "POST create" do
    it "requires authentication" do
      proposal = create(:proposal)

      post :create, params: { proposal_id: proposal.id, body: "Great idea!" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a comment on the proposal for the current user" do
      user = create(:user)
      proposal = create(:proposal)
      sign_in(user)

      post :create, params: { proposal_id: proposal.id, body: "Great idea!" }

      expect(response).to have_http_status(:created)
      comment = proposal.comments.last
      expect(comment.body).to eq "Great idea!"
      expect(comment.author).to eq user
    end

    it "creates a reply when a parent_id is given" do
      user = create(:user)
      proposal = create(:proposal)
      parent = create(:comment, commentable: proposal)
      sign_in(user)

      post :create, params: { proposal_id: proposal.id, body: "I agree!", parent_id: parent.id }

      expect(response).to have_http_status(:created)
      expect(proposal.comments.last.parent).to eq parent
    end

    it "returns errors for an invalid comment" do
      user = create(:user)
      proposal = create(:proposal)
      sign_in(user)

      post :create, params: { proposal_id: proposal.id, body: "" }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

module Api
  class CommentsController < Api::BaseController
    before_action :authenticate_user!
    before_action :load_commentable
    before_action :verify_resident_for_commentable!
    before_action :verify_comments_open!
    before_action :build_comment
    load_and_authorize_resource class: Comment

    def create
      if @comment.save
        render json: @comment.as_json(only: [:id, :body, :created_at]), status: :created
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

      def load_commentable
        @commentable = Proposal.find(params[:proposal_id])
      end

      def verify_resident_for_commentable!
        if Comment.resident_verification_required?(@commentable, current_user)
          render json: { error: "Residence verification required" }, status: :forbidden
        end
      end

      def verify_comments_open!
        unless Comment.commentable_open?(@commentable, current_user)
          render json: { error: "Comments are closed" }, status: :forbidden
        end
      end

      def build_comment
        @comment = Comment.build(@commentable, current_user, params[:body], params[:parent_id])
      end
  end
end

module Api
  class ProposalsController < Api::BaseController
    before_action :authenticate_user!, except: [:index, :show]
    load_and_authorize_resource

    PROPOSAL_ATTRIBUTES = [:id, :title, :summary, :description, :cached_votes_up,
                           :comments_count].freeze
    PROPOSAL_METHODS = [:public_created_at].freeze

    def index
      proposals = Proposal.public_for_api.page(params[:page])
      render json: proposals.as_json(only: PROPOSAL_ATTRIBUTES, methods: PROPOSAL_METHODS)
    end

    def show
      render json: proposal_json(@proposal)
    end

    def create
      @proposal = Proposal.create_for(current_user, proposal_params)
      render_proposal(@proposal, status: :created)
    end

    def update
      @proposal.update_with_map_location(proposal_params)
      render_proposal(@proposal)
    end

    def vote
      @follow = @proposal.vote_and_follow!(current_user)
      render json: proposal_json(@proposal)
    end

    private

      def proposal_json(proposal)
        proposal.as_json(only: PROPOSAL_ATTRIBUTES, methods: PROPOSAL_METHODS)
      end

      def render_proposal(proposal, status: :ok)
        if proposal.persisted? && proposal.errors.empty?
          render json: proposal_json(proposal), status: status
        else
          render json: { errors: proposal.errors.full_messages }, status: :unprocessable_content
        end
      end

      def proposal_params
        params.require(:proposal).permit(:title, :summary, :description, :video_url,
                                         :responsible_name, :tag_list, :terms_of_service,
                                         :geozone_id,
                                         map_location_attributes: [:latitude, :longitude, :zoom])
      end
  end
end

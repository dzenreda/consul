module Api
  class SessionsController < Api::BaseController
    skip_authorization_check
    before_action :authenticate_user!, only: :destroy

    def create
      user = User.authenticate(params[:login], params[:password])

      if user
        user.update_tracked_fields!(request)
        sign_in(user, store: false)
        render json: { id: user.id, username: user.username }, status: :created
      else
        render json: { error: "Invalid login or password" }, status: :unauthorized
      end
    end

    def destroy
      sign_out(current_user)
      head :no_content
    end
  end
end

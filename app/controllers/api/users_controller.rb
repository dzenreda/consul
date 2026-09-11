module Api
  class UsersController < Api::BaseController
    skip_authorization_check

    def create
      user = User.register(user_params)
      if user.persisted?
        render json: { id: user.id, username: user.username }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

      def user_params
        params.require(:user).permit(:username, :email, :password, :password_confirmation,
                                     :terms_of_service)
      end
  end
end

module Api
  class BaseController < ActionController::Base
    include FeatureFlags

    feature_flag :api

    skip_before_action :verify_authenticity_token
    check_authorization

    # Without this, Devise decides the response format from `request_format`
    # and, not being JSON, responds to an authentication failure with a 302
    # redirect instead of a 401 JSON body.
    before_action { request.format = :json }

    rescue_from CanCan::AccessDenied do
      render json: { error: "Access denied" }, status: :forbidden
    end

    rescue_from FeatureFlags::FeatureDisabled do
      render json: { error: "Feature disabled" }, status: :forbidden
    end
  end
end

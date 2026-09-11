module Api
  class DocsController < ActionController::Base
    include FeatureFlags

    feature_flag :api
    layout false

    def index; end

    def openapi
      render plain: Rails.root.join("config/openapi.yaml").read, content_type: "application/yaml"
    end
  end
end

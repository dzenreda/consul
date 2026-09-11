require "rails_helper"

describe Api::DocsController do
  render_views

  describe "GET index" do
    it "renders the Redoc viewer" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<redoc")
    end
  end

  describe "GET openapi" do
    it "serves the OpenAPI spec as YAML" do
      get :openapi

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/yaml")
      expect(YAML.safe_load(response.body)["openapi"]).to eq "3.0.3"
    end
  end
end

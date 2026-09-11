class RenameGraphqlApiFeatureSetting < ActiveRecord::Migration[8.0]
  def up
    Setting.rename_key(from: "feature.graphql_api", to: "feature.api")
  end

  def down
    Setting.rename_key(from: "feature.api", to: "feature.graphql_api")
  end
end

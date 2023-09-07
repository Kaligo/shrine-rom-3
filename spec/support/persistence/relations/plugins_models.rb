# frozen_string_literal: true

module Persistence
  module Relations
    class PluginsModels < ROM::Relation[:sql]
      schema(:plugins_models, infer: true) do
      end
    end
  end
end

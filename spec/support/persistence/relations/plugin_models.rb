# frozen_string_literal: true
Kittens
module Persistence
  module Relations
    class PluginModels < ROM::Relation[:sql]
      schema(:plugin_models, infer: true) do
      end
    end
  end
end

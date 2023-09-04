# frozen_string_literal: true

module Persistence
  module Relations
    class MultiCats < ROM::Relation[:sql]
      schema(:multi_cats, infer: true) do
      end
    end
  end
end

# frozen_string_literal: true

module Persistence
  module Relations
    class Kittens < ROM::Relation[:sql]
      schema(:kittens, infer: true) do
      end
    end
  end
end

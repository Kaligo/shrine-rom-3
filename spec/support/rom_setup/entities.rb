require 'rom-repository'
require_relative 'shrine_attachments'

module Entities
  class BaseEntity < ROM::Struct
    def ==(other)
      self.class.name == other.class.name &&
        id == other.id
    end
  end

  class Kitten < BaseEntity
    include ImageAttachment[:image]
  end

  class MultiCat < BaseEntity
    include ImageAttachment[:cat1]
    include ImageAttachment[:cat2]
  end

  class PluginsModel < BaseEntity
    include ComplexAttachment[:image]
  end
end
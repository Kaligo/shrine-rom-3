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
    include ImageAttachment::Attachment.new(:image)
  end

  class MultiCat < BaseEntity
    include ImageAttachment::Attachment.new(:cat1)
    include ImageAttachment::Attachment.new(:cat2)
  end

  class PluginsModel < BaseEntity
    include ComplexAttachment::Attachment.new(:image)
  end
end
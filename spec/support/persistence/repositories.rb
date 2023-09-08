require_relative 'shrine_attachments'
require_relative 'model'

module Repositories
  class BaseRepository < ROM::Repository::Root
    struct_namespace Entities
    auto_struct true
    commands delete: :by_pk

    def self.inherited(child_class)
      super(child_class)
    end

    def self.new
      super(Model.container)
    end

    def find(id)
      root.by_pk(id).one
    end

    def where(args = {})
      root.where(**args).to_a
    end

    def all
      root.to_a
    end

    def first
      root.first
    end

    def last
      root.reverse.limit(1).first
    end

    def create(attrs)
      if attrs.is_a?(Array)
        raise NotImplementedError.new(
          'ApplicationRepository#create does not support creating many records. Use #create_many instead.'
        )
      end

      cs = changeset(attrs).map do |tuple|
        now = Time.now
        hash_of_timestamps = %i(created_at updated_at).each_with_object({}) do |timestamp_field, hash|
          hash[timestamp_field] = now unless tuple[timestamp_field]
        end

        next tuple.merge(hash_of_timestamps) if hash_of_timestamps.any?

        tuple
      end

      map_tuple(cs.relation, cs.commit)
    end

    def update(id, attrs)
      cs = changeset(id, attrs).map do |tuple|
        next tuple.merge(updated_at: Time.now) unless tuple[:updated_at]

        tuple
      end

      returned_data = cs.commit

      return if returned_data.empty?

      map_tuple(cs.relation, returned_data)
    end

    def create_many(arr_of_attrs, opts = {})
      now = Time.now

      arr_of_attrs_with_timestamps = arr_of_attrs.map do |attrs|
        dup_attrs = attrs.dup

        dup_attrs.transform_values! do |value|
          next Sequel.pg_jsonb(value) if value.is_a?(Hash) || value.is_a?(Array)

          value
        end

        now = Time.now if opts[:has_sequential_timestamp]
        dup_attrs[:created_at] ||= now
        dup_attrs[:updated_at] ||= now

        dup_attrs
      end

      returned_array = root.dataset.returning.multi_insert(arr_of_attrs_with_timestamps)

      root.mapper.(returned_array)
    end

    def aggregate(*args)
      if args.all? { |arg| arg.is_a?(Symbol) }
        root.combine(*args)
      else
        args.reduce(root) { |a, e| a.combine(e) }
      end
    end

    def clear
      root.delete
    end

    def entity_class
      root.mapper.model
    end

    def count
      root.count
    end
  end

  class KittenRepository < BaseRepository[:kittens]
    # prepend ImageAttachment.repository(:image)
  end
  
  class MultiCatRepository < BaseRepository[:multi_cats]
    # prepend ImageAttachment.repository(:cat1)
    # prepend ImageAttachment.repository(:cat2)
  end
  
  class PluginsModelRepository < BaseRepository[:plugins_models]
    # prepend ComplexAttachment.repository(:image)
  end
end

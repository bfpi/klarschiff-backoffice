# frozen_string_literal: true

module Citysdk
  module Serialization
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model
      include ActiveModel::Serialization

      cattr_accessor :serialization_attributes
      mattr_reader :config, default: Config.for(:citysdk)
    end

    def attributes
      hsh = {}
      self.class.serialization_attributes.each do |attr|
        hsh[attr] = nil
      end
      hsh
    end

    def to_xml(options)
      serializable_hash(serialization_options(options)).to_xml options.merge(
        root: options[:element_name] || self.class.name.underscore
      )
    end

    def as_json(options)
      serializable_hash(serialization_options(options))
    end

    private

    def serialization_options(options)
      {}.tap do |hsh|
        hsh[:methods] = serializable_methods(options) if respond_to? :serializable_methods, true
      end
    end

    # https://github.com/rails/rails/pull/44770 -> we need the serialization method from ActiveModel
    def attribute_names_for_serialization
      attributes.keys
    end
  end
end

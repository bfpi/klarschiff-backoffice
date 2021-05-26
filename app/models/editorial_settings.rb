# frozen_string_literal: true

class EditorialSettings
  (@config ||= Config.for(:editorial)).with_indifferent_access.each do |context, options|
    m = Module.new
    options.each do |name, value|
      m.define_singleton_method(name.to_s) { value }
    end
    const_set context.classify, m
  end
end

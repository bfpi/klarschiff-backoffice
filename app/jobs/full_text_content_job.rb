# frozen_string_literal: true

class FullTextContentJob < ApplicationJob
  def perform
    FullTextContent.delete_all

    Dir['app/models/*.rb'].map { |f| File.basename(f, '.*').camelize.constantize }
      .each { |m| m.all.each { |obj| obj.send(:update_full_text) } if exec_update_fill_text?(m) }
  end

  private

  def exec_update_fill_text?(mod)
    mod.respond_to?(:abstract_class?) && !mod.abstract_class? && mod.new.private_methods.include?(:update_full_text)
  end
end

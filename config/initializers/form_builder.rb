# frozen_string_literal: true

module ActionView
  module Helpers
    class FormBuilder
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TranslationHelper

      def multiselect_filter_field(method, options = {})
        options[:value] = ''
        rows = safe_join([head(options), filter_body(method, options)].flatten)
        table = tag.table(rows, class: :table)
        tag.div(table + autocomplete_field("filter[#{method}][]", options), class: 'select-many')
      end

      def select_many_field(method, options = {})
        options[:value] = ''
        rows = safe_join([head(options), body(method, options)].flatten)
        table = tag.table(rows, class: :table)
        tag.div(table + autocomplete_field("#{method}][", options), class: 'select-many')
      end

      def head(options)
        options[:columns].split(',').map do |col|
          tag.th(options[:object].human_attribute_name(col.strip))
        end << tag.th(t('actions'), class: :action)
      end

      def filter_body(method, options)
        options[:object].where(id: options[:filter_ids]).map do |entry|
          tag.tr(tag.td(hidden_input(method, 'filter', entry)) + tag.td(trash_button, class: 'action text-center'))
        end
      end

      def body(method, options)
        options[:object].find(object.send(method)).map do |entry|
          tag.tr(tag.td(hidden_input(method, class_name, entry)) + tag.td(trash_button, class: 'action text-center'))
        end
      end

      def hidden_input(method, name, entry)
        tag.input(type: :hidden, value: entry.id, name: "#{name}[#{method}][]") + entry.to_s
      end

      def trash_button
        link_to(tag.i('', class: 'fa fa-trash'), '#', class: 'btn btn-sm btn-outline-primary')
      end

      def class_name
        object.class.name.downcase
      end

      def autocomplete_field(method, options = {})
        tag.div(text_field(method, options) + tag.div('', class: 'spinner-border'),
          class: 'autocomplete ui-front')
      end
    end
  end
end

# frozen_string_literal: true

require 'rubyXL'
require 'rubyXL/convenience_methods'

class IssuesController
  module Export
    extend ActiveSupport::Concern

    private

    def xlsx_export
      wb = RubyXL::Workbook.new
      sheet = wb[0]
      xlsx_header sheet
      column_widths sheet
      xlsx_content sheet
      send_data wb.stream.read, filename: "#{Issue.model_name.human(count: :other)}.xlsx", disposition: 'attachment'
    end

    def xlsx_header(worksheet)
      Issue::EXPORT_ATTRIBUTES.each_with_index do |attr, idx|
        worksheet.add_cell 0, idx, header_value(attr)
      end
      header_properties worksheet
    end

    def column_widths(worksheet)
      Issue::EXPORT_ATTRIBUTES.each_with_index do |attr, idx|
        worksheet.change_column_width idx, column_width(attr)
      end
    end

    def column_width(attr)
      case attr
      when :address then 80
      when :main_category, :sub_category then 50
      when :created_at, :status, :district, :delegation, :group, :updated_at then 30
      when :kind, :priority, :supporters then 20
      else
        10
      end
    end

    def header_properties(worksheet)
      Issue::EXPORT_ATTRIBUTES.count.times do |col|
        (cell = worksheet.sheet_data[0][col]).change_fill 'bfbfbf'
        cell.change_font_bold true
        cell.change_horizontal_alignment 'center'
      end
    end

    def xlsx_content(worksheet)
      @issues.find_each.with_index do |issue, idx|
        write_content_row(worksheet, issue, idx + 1)
      end
    end

    def write_content_row(worksheet, issue, row)
      Issue::EXPORT_ATTRIBUTES.each_with_index do |attr, col|
        worksheet.add_cell row, col, cell_value(issue, attr)
      end
    end

    def header_value(attr)
      case attr
      when :kind then MainCategory.human_attribute_name(:kind)
      when :main_category, :sub_category then Category.human_attribute_name(attr)
      when :district then District.model_name.human
      else
        Issue.human_attribute_name(attr)
      end
    end

    def cell_value(issue, attr)
      return send(:"cell_value_#{attr}", issue) if respond_to? :"cell_value_#{attr}", true
      case attr
      when :created_at, :updated_at then I18n.l(issue[attr])
      when :status, :priority then Issue.human_enum_name(attr, issue[attr])
      when :district then nil
      else
        issue.send(attr).to_s
      end
    end

    def cell_value_kind(issue)
      issue.kind_name
    end

    def cell_value_supporters(issue)
      issue.supporters.count
    end

    def cell_value_group(issue)
      issue.group.name
    end

    def cell_value_delegation(issue)
      issue.delegation&.name
    end
  end
end

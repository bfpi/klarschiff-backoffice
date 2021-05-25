# frozen_string_literal: true

require 'rubyXL'
require 'rubyXL/convenience_methods'

class DelegationsController
  module Export
    extend ActiveSupport::Concern

    private

    def xlsx_export
      wb = RubyXL::Workbook.new
      sheet = wb[0]
      xlsx_header sheet
      column_widths sheet
      xlsx_content sheet
      send_data wb.stream.read, filename: "#{Issue.model_name.human(count: 2)}.xlsx", disposition: 'attachment'
    end

    def column_widths(worksheet)
      Issue::DELEGATION_EXPORT_ATTRIBUTES.each_with_index do |attr, idx|
        worksheet.change_column_width idx, column_width(attr)
      end
    end

    def column_width(attr)
      case attr
      when :address then 80
      when :main_category, :sub_category then 50
      when :created_at, :status then 30
      when :kind, :priority then 20
      else
        10
      end
    end

    def xlsx_header(worksheet)
      Issue::DELEGATION_EXPORT_ATTRIBUTES.each_with_index do |attr, idx|
        worksheet.add_cell 0, idx, header_value(attr)
      end
      header_properties worksheet
    end

    def header_properties(worksheet)
      Issue::DELEGATION_EXPORT_ATTRIBUTES.count.times do |col|
        (cell = worksheet.sheet_data[0][col]).change_fill '0000ff'
        cell.change_font_bold true
        cell.change_horizontal_alignment 'center'
      end
    end

    def xlsx_content(worksheet)
      @issues.each_with_index do |issue, idx|
        write_content_row worksheet, issue, idx + 1
      end
    end

    def write_content_row(worksheet, issue, row)
      Issue::DELEGATION_EXPORT_ATTRIBUTES.each_with_index do |attr, col|
        worksheet.add_cell row, col, cell_value(issue, attr)
      end
    end

    def header_value(attr)
      case attr
      when :kind then MainCategory.human_attribute_name(:kind)
      when :main_category, :sub_category then Category.human_attribute_name(attr)
      else
        Issue.human_attribute_name(attr)
      end
    end

    def cell_value(issue, attr)
      case attr
      when :created_at then I18n.l issue[attr]
      when :kind then MainCategory.human_enum_name attr, issue.kind
      when :status, :priority then Issue.human_enum_name attr, issue[attr]
      else
        issue.send(attr).to_s
      end
    end
  end
end

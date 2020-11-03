# frozen_string_literal: true

class IssueExportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @issue = Issue.find(params[:issue_id])
    @map_image = Base64.decode64(params[:map_image])
    str = render_to_string(template: 'issue_exports/create', formats: :html, layout: false)
    kit = PDFKit.new(str.to_s,
      page_size: 'A4',
      margin_top: '0.5in',
      margin_right: '0.5in',
      margin_bottom: '0.5in',
      margin_left: '0.5in')
    send_data kit.to_pdf, filename: 'Druckansicht.pdf', disposition: :attachment
  end
end

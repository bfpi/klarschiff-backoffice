# frozen_string_literal: true

class IssueExportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @issue = Issue.find(params[:issue_id])
    @map_image = Base64.decode64(params[:map_image])
    headers['X-FileName'] = (file_name = "meldung-#{@issue.id}.pdf")
    send_data pdf, filename: file_name, disposition: :attachment
  end

  private

  def pdf
    PDFKit.new(
      render_to_string(template: 'issue_exports/create', formats: :html, layout: false,
        locals: { restricted: params[:restricted]&.to_boolean }),
      root_url: "#{request.base_url}/", page_size: 'A4', margin_top: '0.5in', margin_right: '0.5in',
      margin_bottom: '0.5in', margin_left: '0.5in'
    ).to_pdf
  end
end

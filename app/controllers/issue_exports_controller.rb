# frozen_string_literal: true

class IssueExportsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @issue = Issue.find(params[:issue_id])
    @map_image = Base64.decode64(params[:map_image])
    res = params[:restricted].try(:to_boolean) if params[:restricted].present?
    kit = PDFKit.new(
      render_to_string(template: 'issue_exports/create', formats: :html, layout: false, locals: { restricted: res }),
      root_url: "#{request.base_url}/", page_size: 'A4', margin_top: '0.5in', margin_right: '0.5in',
      margin_bottom: '0.5in', margin_left: '0.5in'
    )
    headers['X-FileName'] = (file_name = "meldung-#{@issue.id}.pdf")
    send_data kit.to_pdf, filename: file_name, disposition: :attachment
  end
end

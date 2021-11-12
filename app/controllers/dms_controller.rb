# frozen_string_literal: true

class DmsController < ApplicationController
  def index
    issue = Issue.find(params[:issue_id])
    dms = Dms.new(issue)
    render plain: dms.exists? ? dms_url(id: issue.id) : dms.link
  end

  def show
    issue = Issue.find(params[:id])
    dms = Dms.new(issue)
    return render plain: I18n.t('dms.no_doc_id') if (doc_id = dms.document_id).blank?
    send_data "idlist\r\n#{doc_id}\r\n\r\n", disposition: :attachment, filename: "#{doc_id} (#{doc_id}).d3l"
  end
end

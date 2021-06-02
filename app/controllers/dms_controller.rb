# frozen_string_literal: true

class DmsController < ApplicationController
  def index
    return if (issue, config, ddc = init(params[:issue_id])).blank?

    if Dms.exists? config, ddc, issue.id
      render plain: url_for(controller: :dms, action: :show, id: issue.id)
    else
      render plain: Dms.create_link(config, ddc, issue)
    end
  end

  def show
    return if (issue, config, ddc = init(params[:id])).blank?

    if (document_id = Dms.document_id(config, ddc, issue.id)).blank?
      content = 'Die d.3-Akte ist zwar vorhanden, jedoch liefert die d.3-API nicht deren Aktennummer zurück, sodass '\
        'die Akte nicht geöffnet werden kann.'
      send_data content, type: 'text/plain;charset=UTF-8'
    else
      content = "idlist\r\n#{document_id}\r\n\r\n"
      send_data content, disposition: :attachment, filename: "#{document_id} (#{document_id}).3dl"
    end
  end

  private

  def init(issue_id)
    issue = Issue.find(issue_id)
    return nil if issue.dms.blank?
    dms, ddc = issue.dms.split(':')
    return nil if (config = Dms[dms.to_sym]).blank?
    [issue, config, ddc]
  end
end

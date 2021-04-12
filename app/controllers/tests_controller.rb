# frozen_string_literal: true

class TestsController < ApplicationController
  include Filter
  before_action { check_auth :test }

  def index; end

  def create
    case params[:test].to_sym
    when :protocol_email
      return render plain: 'Empfänger unbekannt.', status: :bad_request if params[:recipient].blank?
      TestMailer.test(to: params[:recipient]).deliver_now
      return render plain: "Testnachricht an #{params[:recipient]} versandt.", status: :ok
    end
    head :ok
  end
end

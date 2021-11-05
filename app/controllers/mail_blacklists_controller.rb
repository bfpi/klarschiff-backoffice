# frozen_string_literal: true

class MailBlacklistsController < ApplicationController
  include Filter
  include Sorting
  before_action { check_auth :manage_mail_blacklist }

  def index
    mail_blacklists = filter(MailBlacklist.all).order(order_attr)

    respond_to do |format|
      format.html { @mail_blacklists = mail_blacklists.page(params[:page] || 1).per(params[:per_page] || 20) }
      format.json { render json: mail_blacklists }
    end
  end

  def edit
    @mail_blacklist = MailBlacklist.find(params[:id])
  end

  def new
    @mail_blacklist = MailBlacklist.new
  end

  def update
    @mail_blacklist = MailBlacklist.find(params[:id])
    if @mail_blacklist.update(mail_blacklist_params) && params[:save_and_close].present?
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @mail_blacklist = MailBlacklist.new mail_blacklist_params
    if @mail_blacklist.save
      if params[:save_and_close].present?
        redirect_to action: :index
      else
        render :edit
      end
    else
      render :new
    end
  end

  private

  def mail_blacklist_params
    params.require(:mail_blacklist).permit(:active, :pattern, :source, :reason)
  end

  def filter_name_columns
    %i[pattern source reason]
  end

  def default_order
    :pattern
  end
end

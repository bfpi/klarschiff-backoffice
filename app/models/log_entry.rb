# frozen_string_literal: true

class LogEntry < ApplicationRecord
  belongs_to :auth_code, optional: true
  belongs_to :issue, optional: true
  belongs_to :user, optional: true

  class << self
    def authorized(user = Current.user)
      return all if user&.role_admin?
      return none unless user&.role_regional_admin?
      authorized_issues(user)
        .or(authorized_users(user))
        .or(authorized_groups(user))
        .or(authorized_responsibilities(user))
    end

    def authorized_issues(user = Current.user)
      where.not(issue_id: nil).where issue_id: Issue.authorized(user)
    end

    def authorized_users(user = Current.user)
      where table: :user, subject_id: Group.authorized(user)
    end

    def authorized_groups(user = Current.user)
      where(arel_table[:table].matches('%group')).where subject_id: Group.authorized(user)
    end

    def authorized_responsibilities(user = Current.user)
      where table: :responsibility, subject_id: Responsibility.authorized(user)
    end

    def authorized_mail_blacklists
      where table: :mail_blacklist
    end
  end
end

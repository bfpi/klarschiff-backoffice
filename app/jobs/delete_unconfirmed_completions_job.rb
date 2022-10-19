# frozen_string_literal: true

class DeleteUnconfirmedCompletionsJob < ApplicationJob
  def perform
    unconfirmed_completions(JobSettings::Completion.deletion_deadline_days.days.ago).destroy_all
  end

  private

  def unconfirmed_completions(time)
    Completion.unscoped.where(completion_arel_table[:confirmed_at].eq(nil)
      .and(completion_arel_table[:created_at].lt(time)))
  end
end

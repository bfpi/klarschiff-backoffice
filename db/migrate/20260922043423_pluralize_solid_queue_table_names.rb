# frozen_string_literal: true

class PluralizeSolidQueueTableNames < ActiveRecord::Migration[8.1]
  def change
    rename_table 'solid_queue_blocked_execution', 'solid_queue_blocked_executions'
    rename_table 'solid_queue_claimed_execution', 'solid_queue_claimed_executions'
    rename_table 'solid_queue_failed_execution', 'solid_queue_failed_executions'
    rename_table 'solid_queue_job', 'solid_queue_jobs'
    rename_table 'solid_queue_pause', 'solid_queue_pauses'
    rename_table 'solid_queue_process', 'solid_queue_processes'
    rename_table 'solid_queue_ready_execution', 'solid_queue_ready_executions'
    rename_table 'solid_queue_recurring_execution', 'solid_queue_recurring_executions'
    rename_table 'solid_queue_recurring_task', 'solid_queue_recurring_tasks'
    rename_table 'solid_queue_scheduled_execution', 'solid_queue_scheduled_executions'
    rename_table 'solid_queue_semaphore', 'solid_queue_semaphores'
  end
end

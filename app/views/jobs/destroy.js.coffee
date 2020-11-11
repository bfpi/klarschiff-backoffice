$("#<%= @group_id %>-table").replaceWith("<%= j render(partial: 'jobs_table', locals: { jobs: @jobs, group_id: @group_id }) %>")

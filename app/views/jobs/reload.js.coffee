$("#group-<%= @jobs.first.group_id %>-table").replaceWith(
  "<%= j render(partial: 'jobs_table', locals: { jobs: @jobs, group_id: @jobs.first.group_id }) %>"
)
KS.initDnD()

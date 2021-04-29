$("tr#job-<%= @job.id %>").replaceWith("<%= j render(partial: 'job', locals: { job: @job }) %>")
KS.initDnD()

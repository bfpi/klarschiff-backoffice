#= require tablednd

$ ->
  $(document).ready KS.initDnD
  $(document).on 'turbolinks:load', KS.initDnD

  $(document).on 'click', '.select-all', ->
    $(@).parents('table').find('.selectable').prop('checked', @.checked)

  $(document).on 'click', '.change-status', ->
    ids = $($(@).data('table')).find('.selectable').toArray().filter((e) -> e.checked).map((e) -> e.value)
    return if ids.length == 0
    KS.updateMultipleJobs $.param({ job_ids: ids, job: { status: $(@).data('status') } })

  $(document).on 'click', '.change-date', ->
    ids = $($(@).data('table')).find('.selectable').toArray().filter((e) -> e.checked).map((e) -> e.value)
    return if ids.length == 0
    KS.updateMultipleJobs $.param({ job_ids: ids, job: { date: $($(@).data('field')).val() } })

KS.initDnD = ->
  $('.table-draggable').tableDnD onDragClass: 'dragged-row'

KS.updateMultipleJobs = (params) ->
  $.ajax
    url: '/jobs/update_multiple'
    data: params
    dataType: 'script'
    method: 'PUT'


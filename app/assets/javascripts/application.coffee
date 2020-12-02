#= require rails-ujs
#= require jquery
#= require jquery-ui
#= require bootstrap
#= require bootstrap-datepicker
#= require tablednd
#= require turbolinks
#= require proj4js
#= require ol
#= require_self
#= require_tree .

window.KS ||= {}

KS.initializeModalFunctions = ->
  KS.initializeIssueAddressAutocomplete()
  KS.initializeFormActions()
  KS.initializeMaps()
  KS.initializePhotoActions()
  KS.initializeSelectManyAutocomplete()
  KS.initializeUserLdapAutocomplete()

$ ->
  $('.modal').on 'hide.bs.modal', ->
    location.reload()

  initDatepicker = ->
    $('.datepicker').datepicker
      format: 'dd.mm.yyyy'
      language: 'de'
      autoclose: true
  
  initDnD = ->
    $('.table-draggable').tableDnD
      onDragClass: 'dragged-row'

  $(document).ready initDatepicker
  $(document).ready initDnD
  $(document).on 'turbolinks:load', initDatepicker
  $(document).on 'turbolinks:load', initDnD

  $(document).on 'click', '.select-all', ->
    $(@).parents('table').find('.selectable').prop('checked', @.checked)

  updateMultipleJobs = (params) ->
    $.ajax
      url: '/jobs/update_multiple'
      data: params
      dataType: 'script'
      method: 'PUT'

  $(document).on 'click', '.change-status', ->
    ids = $($(@).data('table')).find('.selectable').toArray().filter((e) -> e.checked).map((e) -> e.value)
    return if ids.length == 0
    updateMultipleJobs $.param({ job_ids: ids, job: { status: $(@).data('status') } })

  $(document).on 'click', '.change-date', ->
    ids = $($(@).data('table')).find('.selectable').toArray().filter((e) -> e.checked).map((e) -> e.value)
    return if ids.length == 0
    updateMultipleJobs $.param({ job_ids: ids, job: { date: $($(@).data('field')).val() } })

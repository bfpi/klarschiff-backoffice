#= require rails-ujs
#= require jquery
#= require jquery-ui
#= require bootstrap
#= require bootstrap-datepicker
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

  $(document).ready initDatepicker
  $(document).on 'turbolinks:load', initDatepicker

  $(document).on 'click', '.select-all', ->
    $(@).parents('table').find('.selectable').prop('checked', @.checked)

  $(document).on 'click', '.change-status', ->
    ids = $($(@).data('table')).find('.selectable').toArray().filter((e) -> e.checked).map((e) -> e.value)
    console.log(ids)
    return if ids.length == 0
    params = $.param({ job_ids: ids, status: $(@).data('status') })
    $.ajax
      url: '/jobs/update_statuses'
      data: params
      dataType: 'script'
      method: 'PUT'


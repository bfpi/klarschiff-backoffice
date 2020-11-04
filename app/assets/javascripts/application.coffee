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

  $(document).ready ->
    $('.datepicker').datepicker
      format: 'dd.mm.yyyy'
      language: 'de'

  $('#job_date').on 'change', ->
    $.ajax
      url: '/jobs'
      data: { date: $(@).val() }
      dataType: 'script'

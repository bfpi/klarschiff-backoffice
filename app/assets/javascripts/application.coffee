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

  $(document).on 'click', '.change-status', ->
    console.log($(@))

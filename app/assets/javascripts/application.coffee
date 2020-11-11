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

$ ->
  $('.modal').on 'hide.bs.modal', ->
    location.reload()

  $(document).ready KS.initDatepicker
  $(document).on 'turbolinks:load', KS.initDatepicker

  $(document).on 'keypress', '#search_issue', (e) ->
    if (e.key == 'Enter' || e.keyCode == 13)
      $.get
        url: "/issues/#{@.value}/edit"
        method: 'GET'
        dataType: 'script'
    else
      e.preventDefault() unless e.key.match(/[0-9]/)

KS.initializeModalFunctions = ->
  KS.initializeIssueAddressAutocomplete()
  KS.initializeFormActions()
  KS.initializeMaps()
  KS.initializePhotoActions()
  KS.initializeSelectManyAutocomplete()
  KS.initializeUserLdapAutocomplete()
  KS.initDatepicker()

KS.initDatepicker = ->
  $('.datepicker').datepicker(
    format: 'dd.mm.yyyy'
    language: 'de'
    autoclose: true
  ).on 'hide', (e) ->
    # Workaround for: https://github.com/uxsolutions/bootstrap-datepicker/issues/50
    e.stopPropagation()


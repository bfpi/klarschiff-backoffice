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

  $(document).on 'keypress', '#search-issue', (e) ->
    if (e.key == 'Enter' || e.keyCode == 13)
      $.get
        url: "/issues/#{@.value}/edit"
        method: 'GET'
        dataType: 'script'
    else
      e.preventDefault() unless e.key.match(/[0-9]/)

  $(document).on 'ajax:complete', 'form', (data) ->
    $('#notice-success').hide()
    $('#notice-error').hide()
    detail = data.detail[0]
    if detail.response.length > 0
      if detail.status == 200
        $('#notice-success .text').html(detail.response)
        $('#notice-success').show()
      else
        $('#notice-error .text').html(detail.response)
        $('#notice-error').show()

  $(document).on 'click', '.alert .close', (e) ->
    $(e.target).parents('.alert').hide()

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


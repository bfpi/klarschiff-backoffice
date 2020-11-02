#= require rails-ujs
#= require jquery
#= require jquery-ui
#= require bootstrap
#= require turbolinks
#= require proj4js
#= require ol
#= require_self
#= require_tree .

window.KS ||= {}

KS.initializeModalFunctions = ->
  KS.initializeSelectManyAutocomplete()
  KS.initializeUserLdapAutocomplete()
  KS.initializeFormActions()
  KS.initializeMaps()

$ ->
  $('.modal').on 'hide.bs.modal', ->
    location.reload()

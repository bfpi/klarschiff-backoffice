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
  KS.initializeFormActions()
  KS.initializeMaps()
  KS.initializePhotoActions()
  KS.initializeSelectManyAutocomplete()
  KS.initializeUserLdapAutocomplete()

$ ->
  $('.modal').on 'hide.bs.modal', ->
    location.reload()

$ ->
  initializeExtendedFilter = ->
    if $('form#issues-filter').length == 1
      KS.initializeFormActions()

  $(document).on 'turbolinks:load', initializeExtendedFilter
  $(document).ready initializeExtendedFilter

  $(document).on 'change', '#status_note_template', ->
    $('#issue_status_note').val($('#status_note_template')[0]['value'])
    $('#status_note_template').val('')

  $(document).on 'click', '#issue_email_direct', (e) ->
    e.preventDefault()
    $.ajax
      url: $('#issue_email_direct').attr('href')
      type: 'GET'
      success: (data) ->
        location.href = data

  $(document).on 'click', '#issue_export', (e) ->
    $('#print-map').attr('id', 'map') if $('#map').size() == 0
    $('#map').html('')
    KS.initializeMaps()
    e.preventDefault()
    href = $('#issue_export').attr('href')

    window.setTimeout (->
      canvas = document.getElementsByTagName('canvas').item(0)
      img = canvas.toDataURL('image/png')

      req = new XMLHttpRequest
      req.open 'POST', $('#issue_export').attr('href'), true
      req.responseType = 'blob'
      req.setRequestHeader "Content-Type", "application/x-www-form-urlencoded; charset=UTF-8"
      req.send 'map_image=' + btoa(img)

      req.onload = (event) ->
        blob = req.response
        link = document.createElement('a')
        link.href = window.URL.createObjectURL(blob)
        link.download = req.getResponseHeader('X-FileName')
        link.click()
    ), 1000

  $(document).on 'click', '.card .btn-create', (e) ->
    e.preventDefault()
    link = $(e.target).parents('.card').find('.btn-create')
    $.ajax
      url: link.attr('href')
      type: 'POST'
      data: link.parents('.card').find(':input')

  $(document).on 'click', '.card .btn-update', (e) ->
    e.preventDefault()
    link = $(e.target).parents('.card').find('.btn-update')
    $.ajax
      url: link.attr('href')
      type: 'PUT'
      data: link.parents('.card').find(':input')

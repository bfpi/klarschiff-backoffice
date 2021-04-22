
KS.initializeIssueAddressAutocomplete = ->
  if $('#modal #issue_address').length == 0
    return
  input = $('#modal #issue_address')
  input.autocomplete
    minLength: 3
    source: (request, response) ->
      $.ajax(
        url: input.data('autocomplete-url')
        dataType: 'json'
        data:
          pattern: request.term
        success: (data) ->
          response(data)
      )
    select: (event, ui) ->
      features = KS.findLayerById('features').getSource().getFeatures()
      if features.length == 1
        x = ui.item.bbox[0] + (ui.item.bbox[2] - ui.item.bbox[0]) / 2
        y = ui.item.bbox[1] + (ui.item.bbox[3] - ui.item.bbox[1]) / 2
        pos = [x, y]
        feature = features[0]
        feature.getGeometry().setCoordinates(pos)
        KS.setFeatureCoordinatesToInput(feature)
        KS.Map.getView().setCenter(pos)

KS.initializeSelectManyAutocomplete = ->
  $('.select-many .autocomplete input').each (ix, elem) ->
    input = $(elem)
    input.autocomplete(
      minLength: 3
      source: input.data('autocomplete-url')
      search: (event, ui) ->
        $(this).parent('.autocomplete').find('.spinner-border').show()
      response: (event, ui) ->
        $(this).parent('.autocomplete').find('.spinner-border').hide()
      select: (event, ui) ->
        tr = $(event.target).parents('.select-many').find('tr').last()
        hidden = $('<input>').attr('type', 'hidden')
        hidden.attr 'name', $(event.target).attr('name')
        hidden.attr 'value', ui.item.value
        button = $('<a>').attr('href', '#')
        button.attr 'class', 'btn btn-sm btn-outline-primary'
        button.html '<i class="fa fa-trash"></i>'
        tr.after "<tr><td>#{hidden.prop('outerHTML')}#{ui.item.label}</td><td>#{button.prop('outerHTML')}</td></tr>"
        ui.item.value = ''
    ).on 'blur', (event) ->
      $(this).val ''
  $('.select-many').on 'keyup change', 'input[data-autocomplete-url]', (event) ->
    input = $(event.target)
    if input.val().length < 3
      return
    exclude = Array()
    $('input[name="' + $(this).attr('name') + '"]').each (i, ex) ->
      if parseInt($(ex).val()) > 0
        exclude.push parseInt($(ex).val())
      return
    url = input.data('autocomplete-url')
    if exclude.length > 0
      url += '?exclude_ids=' + exclude
    input.autocomplete 'option', 'source', url
    input.autocomplete 'search', input.val()
  $('.select-many').on 'click', 'a', (event) ->
    $(event.target).parents('tr').remove()
    event.preventDefault()

KS.initializeUserLdapAutocomplete = ->
  if $('#modal #user_ldap').length == 0
    return
  input = $('#modal #user_ldap')
  input.autocomplete
    source: input.data('autocomplete-url')
    minLength: 3
    search: (event, ui) ->
      $(this).parents('.autocomplete').find('.spinner-border').show()
    open: (event, ui) ->
      $(this).parents('.autocomplete').find('.spinner-border').hide()
    select: (event, ui) ->
      if ui.item.first_name and ui.item.first_name.length > 0 and $('#user_first_name').val().length == 0
        $('#user_first_name').val ui.item.first_name
      if ui.item.last_name and ui.item.last_name.length > 0 and $('#user_last_name').val().length == 0
        $('#user_last_name').val ui.item.last_name
      if ui.item.value and ui.item.value.length > 0 and $('#user_login').val().length == 0
        $('#user_login').val ui.item.value
      if ui.item.email and ui.item.email.length > 0 and $('#user_email').val().length == 0
        $('#user_email').val ui.item.email

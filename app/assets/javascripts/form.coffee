KS.initializeFormActions = ->
  $('form').each (ix, form) ->
    form = $(form)
    dependencies_path = form.data('dependencies')
    if dependencies_path
      form.on 'change', ':input', (elem) ->
        $.ajax(
          url: dependencies_path
          method: 'PATCH'
          data:
            authenticity_token: $(form).find('#authenticity_token').val()
            attribute: elem.target.name
            value: elem.target.value
        ).done ->
          console.debug 'ajax PATCH on form change:input done'
    form.find(':input[type=file]').imageUploadResizer
      max_width: 2000
      max_height: 2000
      quality: 1
      do_not_resize: [
        'gif'
        'svg'
      ]

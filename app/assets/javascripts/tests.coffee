$ ->
  $(document).on 'ajax:complete', 'form.test', (data) ->
    return if @.id == 'issues-filter'
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

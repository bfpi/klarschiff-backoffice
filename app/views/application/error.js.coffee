message = '<%= j render partial: 'errors', locals: { object: @record } %>'
if ($('#modal').hasClass('hide'))
  $('.content.container').prepend(message)
else
  $('#modal .modal-body').html(message)
  $('#modal').modal('show')

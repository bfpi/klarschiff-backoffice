message = '<%= j @message %>'
if ($('#modal').hasClass('hide'))
  $('.content.container').prepend("<div class='alert alert-danger' role='alert'>#{message}</div>")
else
  $('#modal .modal-body').html(message)
  $('#modal').modal('show')

if $('.edit_issue .modal-body .alert').size() > 0
  $('.edit_issue .modal-body .alert').remove()

$('.edit_issue .modal-body').prepend("<div class='alert alert-success mx-3 mt-3' role='alert'>E-Mail an die Standardzuständigkeit wurde erneut versandt.</div>")

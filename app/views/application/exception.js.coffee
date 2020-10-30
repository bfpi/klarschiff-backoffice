
$('#modal .modal-body').html('<%= j(t(:internal_server_error) + ': ' + @error.inspect) %>');

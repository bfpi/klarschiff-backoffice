$('#modal').html('<%= j render('new') %>')
$('#modal').on('shown.bs.modal', -> KS.initializeModalFunctions())
$('#modal').modal('show')

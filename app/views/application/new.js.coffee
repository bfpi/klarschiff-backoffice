$('#modal').html('<%= j render('new') %>')
$('#modal').one('shown.bs.modal', -> KS.initializeModalFunctions())
$('#modal').modal('show')

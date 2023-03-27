KS.Map?.dispose()
$('#map').replaceWith('')
$('#modal').html('<%= j render('edit') %>')
<% if params[:tab] -%>
KS.initializeModalFunctions()
<% else -%>
$('#modal').on('shown.bs.modal', -> KS.initializeModalFunctions())
<% end -%>
$('#modal').modal('show')

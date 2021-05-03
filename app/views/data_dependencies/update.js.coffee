<% if @attribute == 'issue[kind]' -%>
  $('#issue_category_id').html("<option value=''></option><%= j grouped_categories(@value) %>")
<% end -%>
<% if @attribute == 'responsibility[group_id]' -%>
  $('#responsibility_category_id').html("<option value=''></option><%= j categories_options(@value) %>")
<% end -%>
<% if @attribute == 'issue[responsibility_action]' -%>
  <% if @value == 'manual' -%>
    $('#manual-responsibility').show()
  <% else -%>
    $('#manual-responsibility').hide()
  <% end -%>
<% end -%>

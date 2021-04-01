<% if @attribute == 'issue[kind]' -%>
  $('#issue_category_id').html(
    "<option value=''></option><%= j options_from_collection_for_select(categories_for_kind(@value), :id, :to_s) %>"
  )
<% end -%>
<% if @attribute == 'issue[responsibility_action]' -%>
  <% if @value == 'manual' -%>
    $('#manual-responsibility').show()
  <% else -%>
    $('#manual-responsibility').hide()
  <% end -%>
<% end -%>

<% if @attribute == 'issue[kind]' -%>
  $('#issue_category_id').html("<option value=''></option><%= j grouped_categories(@value) %>")
<% end -%>
<% if @attribute == 'responsibility[category_id]' -%>
  $('#responsibility_group_id').html("<option value=''></option><%= j  groups_options(@value) %>")
<% end -%>
<% if @attribute == 'issue[responsibility_action]' -%>
  <% if @value == 'manual' -%>
    $('#manual-responsibility').show()
  <% else -%>
    $('#manual-responsibility').hide()
  <% end -%>
<% end -%>
<% if @attribute == 'kind' %>
  $('#main_category').attr('disabled', <%= @value.blank? %>)
  $('#main_category').html("<%= j options_for_select(main_categories(@value)) %>")
<% end %>
<% if @attribute == 'main_category' %>
  $('#sub_category').attr('disabled', <%= @value.blank? %>)
  $('#sub_category').html("<%= j options_for_select(sub_categories(@value)) %>")
<% end %>

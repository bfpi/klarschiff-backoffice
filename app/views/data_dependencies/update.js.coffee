
<% if @attribute == 'issue[kind]' %>
$('#issue_category_id').html("<option value=''></option><%= j options_from_collection_for_select(Category.where(kind: @value).map(&:children).flatten, :id, :to_s) %>");
<% end %>

//= require rails-ujs
//= require jquery
//= require jquery-ui
//= require bootstrap
//= require turbolinks

$(function(){
  $('.modal').on('hide.bs.modal', function () {
    location.reload();
  });
  $('.modal').on('shown.bs.modal', function () {
    initializeUserLdapAutocomplete();
  });
});

function initializeUserLdapAutocomplete() {
  if($('#user-modal #user_ldap').length == 0) {
    return;
  }
  var input = $('#user-modal #user_ldap');
  console.log(input);
  input.autocomplete({
    source: input.data('autocomplete-url'),
    minLength: 2,
    select: function( event, ui ) {
      console.log( "Selected: " + ui.item.value + " aka " + ui.item.label );
    }
  });
}

//= require rails-ujs
//= require jquery
//= require jquery-ui
//= require bootstrap
//= require turbolinks

$(function(){
  $('.modal').on('hide.bs.modal', function () {
    location.reload();
  });
});

function initializeModalFunctions() {
  initializeSelectManyAutocomplete();
  initializeUserLdapAutocomplete();
}

function initializeSelectManyAutocomplete() {
  $('.select-many .autocomplete input').each(function(ix, elem) {
    var input = $(elem);
    input.autocomplete({
      minLength: 3,
      source: input.data('autocomplete-url'),
      search: function(event, ui) {
        $(this).parent('.autocomplete').find('.spinner-border').show();
      },
      response: function(event, ui) {
        $(this).parent('.autocomplete').find('.spinner-border').hide();
      },
      select: function( event, ui ) {
        var tr = $(event.target).parents('.select-many').find('tr').last();

        var hidden = $('<input>').attr('type','hidden');
        hidden.attr('name', $(event.target).attr('name'));
        hidden.attr('value', ui.item.value);
        var button = $('a').attr('href', '#');
        button.attr('class', 'btn btn-sm btn-outline-primary');
        button.html('<i class="fa fa-trash"></i>');
        tr.after('<tr><td>' + hidden.prop('outerHTML') + ui.item.label + '</td><td>' + button.prop('outerHTML') + '</td></tr>');
        ui.item.value = "";
      }
    });
  });
  $('.select-many').on('keyup change', 'input[data-autocomplete-url]', function(event) {
    var input = $(event.target);
    if(input.val().length < 3) {
      return;
    }
    var exclude = Array();
    $('input[name="' + $(this).attr('name') + '"]').each(function(i, ex) {
      if(parseInt($(ex).val()) > 0) {
        exclude.push(parseInt($(ex).val()));
      }
    });
    var url = input.data('autocomplete-url');
    if(exclude.length > 0) {
      url += '?exclude_ids=' + exclude;
    }
    input.autocomplete('option', 'source', url);
    input.autocomplete('search', input.val());
  });

  $('.select-many').on('click', 'a', function(event) {
    $(event.target).parents('tr').remove();
    event.preventDefault();
  });
}

function initializeUserLdapAutocomplete() {
  if($('#user-modal #user_ldap').length == 0) {
    return;
  }
  var input = $('#user-modal #user_ldap');
  input.autocomplete({
    source: input.data('autocomplete-url'),
    minLength: 3,
    search: function(event, ui) {
      $(this).parents('.autocomplete').find('.spinner-border').show();
    },
    open: function(event, ui) {
      $(this).parents('.autocomplete').find('.spinner-border').hide();
    },
    select: function( event, ui ) {
      if(ui.item.first_name && ui.item.first_name.length > 0 && $('#user_first_name').val().length == 0) {
        $('#user_first_name').val(ui.item.first_name);
      }
      if(ui.item.last_name && ui.item.last_name.length > 0 && $('#user_last_name').val().length == 0) {
        $('#user_last_name').val(ui.item.last_name);
      }
      if(ui.item.value && ui.item.value.length > 0 && $('#user_login').val().length == 0) {
        $('#user_login').val(ui.item.value);
      }
      if(ui.item.email && ui.item.email.length > 0 && $('#user_email').val().length == 0) {
        $('#user_email').val(ui.item.email);
      }
    }
  });
}

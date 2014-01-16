$(function() {
  // Autopopulate username from full name
  // If the user manually enters a username, stop doing that
  var manualInput = false;

  $('#signup #user_fullname').on('keydown', function() {
    if (manualInput) return;

    var $name = $(this);
    setTimeout(function() {
      var username = $name.val().toLowerCase().replace(' ', '.');
      $('#user_username').val(username);
    }, 0);
  });

  $('#signup #user_username').on('keydown', function() {
    manualInput = true;
  });
});

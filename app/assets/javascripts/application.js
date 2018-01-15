// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap-sprockets
//= require rails-ujs
//= require_tree .

$(function() {
  // protocols
  $('.clickable-tr').click(function(e) {
    window.location = $(e.target.parentElement).data('link');
  });
  $('.clickable-tr .btn').click(function(e) {
    e.stopPropagation();
    if ($(e.target).data('confirm') != null) {
      if (window.confirm($(e.target).data('confirm'))) {
        return true;
      } else {
        return false;
      }
    }
  });

  // contents
  var hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + ']').tab('show');
  $('.nav-pills a').click(function(e) {
    $(this).tab('show');
  });

  $('.section-link').click(function(e) {
    if ($(e.target).data('link') != '#{protocol_content_path(params[:protocol_id], params[:id], anchor: :sections)}' ) {
      window.location = $(e.target).data('link');
    }
    if ($('#instructions').length > 0) { $('.tab-instructions').removeClass('disabled'); }
    if ($('#example').length > 0) { $('.tab-example').removeClass('disabled'); }
  });

  $('.section-common').click(function(e) {
    $('.tab-instructions').addClass('disabled');
    $('.tab-example').addClass('disabled');
  });

  $('.to-under-review').click(function(e) {
    if (!$('.content-has-reviewer').data('has-reviewer')) {
      window.alert($('.content-has-reviewer').data('message'));
    }
  });

  $('.example-copy-button').click(function(e) {
    if (window.confirm($('.example-copy-button').data('message'))) {
      var data = '<div contenteditable="true">' + $(e.target).parent().prev().html() + '</div>';
      tinymce.get('form-tinymce').setContent(data);
    }
  });
});

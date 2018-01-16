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

var editorTextIsChanged = false;

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

  $('#protocol_sponsors').change(function() {
    if ($('#protocol_sponsors').children(':selected').last().text() === $('#protocol_sponsors').children().last().val()) {
      $('.protocol-sponsor-other-form').show();
    } else {
      $('.protocol-sponsor-other-form').hide();
    }
  });

  $('.protocol-checkbox-form').change(function() {
    if ($('#protocol_study_agent_1').prop('checked') || $('#protocol_study_agent_2').prop('checked')) {
      $('.protocol-has-ind-form').show();
    } else {
      $('.protocol-has-ind-form').hide();
    }
    if ($('#protocol_study_agent_3').prop('checked')) {
      $('.protocol-has-ide-form').show();
    } else {
      $('.protocol-has-ide-form').hide();
    }
  });

  // contents
  var hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + ']').tab('show');
  $('.nav-pills a').click(function(e) {
    $(this).tab('show');
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

  $('input[type=submit]').on('click', function() {
    editorTextIsChanged = false;
    $(window).off('beforeunload');
  });
  $(window).on('beforeunload', function() {
    if (editorTextIsChanged && $('.content-submit-button').length > 0) return '';
  });

  // participations
  $('.check-all-sections').click(function() {
    $('input[type=checkbox]').prop('checked', true);
  });

  $('#participation_role').change(function() {
    if ($('#participation_role').val() == $('#participation_role').children().last().val()) {
      $('input[type=checkbox]').prop('checked', true);
      $('.participation-sections').hide();
    } else {
      $('input[type=checkbox]').prop('checked', false);
      $('.participation-sections').show();
    }
  });
});

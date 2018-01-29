/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

const $ = require('jquery');
window.$ = window.jQuery = $;

const Rails = require('rails-ujs');
Rails.start();

require('bootstrap-sass');

const Editor = require('./tiny_mce');

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

  function check_sponsor() {
    if ($('#protocol_sponsors').children(':selected').last().text() === $('#protocol_sponsors').children().last().val()) {
      $('.protocol-sponsor-other-form').show();
    } else {
      $('.protocol-sponsor-other-form').hide();
    }
  }
  $('#protocol_sponsors').change(function() {
    check_sponsor();
  });
  check_sponsor();

  function check_get() {
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
  }
  $('.protocol-checkbox-form').change(function() {
    check_get();
  });
  check_get();

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
    $(window).off('beforeunload');
  });
  $(window).on('beforeunload', function() {
    if (Editor.textIsChanged && $('.content-submit-button').length > 0) return '';
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

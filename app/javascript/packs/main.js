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
require('./tiny_mce');

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

  function checkSponsor() {
    if ($('#protocol_sponsors').children(':selected').last().text() === $('#protocol_sponsors').children().last().val()) {
      $('.protocol-sponsor-other-form').show();
    } else {
      $('.protocol-sponsor-other-form').hide();
    }
  }
  $('#protocol_sponsors').change(function() {
    checkSponsor();
  });
  checkSponsor();

  function checkGet() {
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
    checkGet();
  });
  checkGet();

  // contents
  const hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + ']').tab('show');
  $('.nav-pills a').click(function() {
    $(this).tab('show');
  });

  $('.to-under-review').click(function() {
    if (!$('.content-has-reviewer').data('has-reviewer')) {
      window.alert($('.content-has-reviewer').data('message'));
    }
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
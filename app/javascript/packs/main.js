/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'es6-shim'

import $ from 'jquery'
window.$ = window.jquery = $;

import 'bootstrap-sass'

import Rails from 'rails-ujs'
Rails.start();

import './tiny_mce'
import './protocol'
import './history'
import './comment'

$(() => {
  // protocol form
  function checkSponsor() {
    if ($('#protocol_sponsors').children(':selected').last().text() === $('#protocol_sponsors').children().last().val()) {
      $('.protocol-sponsor-other-form').show();
    } else {
      $('.protocol-sponsor-other-form').hide();
    }
  }
  $('#protocol_sponsors').change(() => {
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
  $('.protocol-checkbox-form').change(() => {
    checkGet();
  });
  checkGet();

  function checkFile() {
    if ($('.upload-field').val().length > 0) {
      $('.upload-button').prop('disabled', false);
    } else {
      $('.upload-button').prop('disabled', true);
    }
  }
  $('.upload-field').change(function() {
    checkFile();
  });
  if ($('.upload-field').length) {
    checkFile();
  }

  // contents
  const hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + ']').tab('show');
  $('.nav-pills a').click((e) => {
    $(e.target).tab('show');
  });

  $('.to-under-review').click(() => {
    if (!$('.content-has-reviewer').data('has-reviewer')) {
      window.alert($('.content-has-reviewer').data('message'));
    }
  });

  // participations
  $('.check-all-sections').click(() => {
    $('input[type=checkbox]').prop('checked', true);
  });

  function checkSections() {
    if ($('#participation_role').val() == $('#participation_role').children().last().val()) {
      $('.participation-sections').hide();
    } else {
      $('.participation-sections').show();
    }
  }
  $('#participation_role').change(function() {
    checkSections();
  });
  checkSections();
});

/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'es6-shim'
import React from 'react'
import ReactDOM from 'react-dom'
import 'bootstrap-sass'

import Rails from 'rails-ujs'
Rails.start();

import './tiny_mce'
import './protocol'
import { HistoryIndex, HistoryCompare } from './history'
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

  // contents
  const hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + ']').tab('show');
  $('.nav-pills a').click(() => {
    $(this).tab('show');
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

  $('#participation_role').change(() => {
    if ($('#participation_role').val() == $('#participation_role').children().last().val()) {
      $('input[type=checkbox]').prop('checked', true);
      $('.participation-sections').hide();
    } else {
      $('input[type=checkbox]').prop('checked', false);
      $('.participation-sections').show();
    }
  });

  // history
  $('.history-button').click((e) => {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done((res) => {
      let target = $('.history-index');
      ReactDOM.render(
        React.createElement(HistoryIndex, { data: res, headers: target.data('headers'), buttons: target.data('buttons') }),
        $('.history-index')[0]
      );
      $('.history-modal').modal('show');
    });
  });

  $(document).on('click', '.compare-button', (e) => {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done((res) => {
      ReactDOM.render(
        React.createElement(HistoryCompare, { data: res.data, text: $('.history-compare').data('text') }),
        $('.history-compare')[0]
      );
      $('.history-index').hide();
    });
  });

  $(document).on('click', '.history-compare-back', () => {
    ReactDOM.unmountComponentAtNode($('.history-compare')[0]);
    $('.history-index').show();
  });

  $('.history-revert').on('confirm:complete', (e, answer) => {
    if (answer) {
      $('.history-modal').modal('hide');
    }
  });
});

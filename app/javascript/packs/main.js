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

import React from 'react'
import ReactDOM from 'react-dom'

import './tiny_mce'
import { ProtocolIndex } from './protocol'
import { ShowCommentButton } from './comment'
import { ShowHistoryButton } from './history'

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

document.addEventListener('DOMContentLoaded', () => {
  const commentButton = document.querySelector('.comment-button');
  if (commentButton) {
    const commentButtonData = JSON.parse(commentButton.dataset.button);
    const commentModalData = JSON.parse(commentButton.dataset.modal);

    ReactDOM.render(
      React.createElement(ShowCommentButton,
                         {
                           buttonData: commentButtonData,
                           modalData: commentModalData,
                           onCommentSubmitted: (json) => {
                             document.querySelector(`#section-${json.id}-comment-icon`).innerHTML = '<i class="fa fa-commenting mr-s">';
                           }
                         },
                         null),
      commentButton
    );
  }

  const historyButton = document.querySelector('.history-button');
  if (historyButton) {
    const historyModalData = JSON.parse(historyButton.dataset.modal);

    ReactDOM.render(
      React.createElement(ShowHistoryButton,
                          { text: historyButton.dataset.text, modalData: historyModalData },
                          null),
      historyButton
    );
  }

  const protocolIndex = document.querySelector('.protocol-index');
  if (protocolIndex) {
    const formData = JSON.parse(protocolIndex.dataset.form);
    ReactDOM.render(
      React.createElement(ProtocolIndex,
                          {
                            placeholder: formData.placeholder,
                            text: formData.text,
                            url: formData.url,
                            headers: formData.headers,
                            buttons: formData.buttons
                          },
                          null),
      protocolIndex
    );
  }
});

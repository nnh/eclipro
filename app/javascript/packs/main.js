/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'es6-shim'

import Rails from 'rails-ujs'
Rails.start();

import React from 'react'
import ReactDOM from 'react-dom'

import './tiny_mce'
import Header from './header'
import { ProtocolIndex } from './protocol'
import { ShowCommentButton } from './comment'
import { ShowHistoryButton } from './history'
import ContentTabs from './content_tabs'

document.addEventListener('DOMContentLoaded', () => {
  // header
  const header = document.querySelector('.ecripro-header');
  const headerData = header.dataset;
  if (header) {
    ReactDOM.render(
      React.createElement(
        Header,
        {
          signedIn: headerData.signedIn,
          protocolUrl: headerData.protocolUrl,
          protocolText: headerData.protocolText,
          newProtocolUrl: headerData.newProtocolUrl,
          newProtocolText: headerData.newProtocolText,
          helpText: headerData.helpText,
          currentUserText: headerData.currentUserText,
          editUrl: headerData.editUrl,
          editText: headerData.editText,
          signOutUrl: headerData.signOutUrl,
          signOutText: headerData.signOutText,
          languageText: headerData.languageText,
          japaneseText: headerData.japaneseText,
          englishText: headerData.englishText,
          languageUrl: headerData.languageUrl,
          signInUrl: headerData.signInUrl,
          signInText: headerData.signInText
        },
        null
      ),
      header
    );
  }

  // protocol index
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

  // protocol form
  const sponsors = document.querySelector('#protocol_sponsors');
  if (sponsors) {
    function checkSponsor() {
      if (sponsors.selectedOptions.length && sponsors.selectedOptions[sponsors.selectedOptions.length - 1].value === sponsors.lastChild.value) {
        document.querySelector('.protocol-sponsor-other-form').style.display = 'block';
      } else {
        document.querySelector('.protocol-sponsor-other-form').style.display = 'none';
      }
    }
    sponsors.addEventListener('change', () => checkSponsor());
    checkSponsor();
  }

  const checkboxes = document.querySelectorAll('.protocol-checkbox-form');
  if (checkboxes.length) {
    function checkGet() {
      if (document.querySelector('#protocol_study_agent_1').checked || document.querySelector('#protocol_study_agent_2').checked) {
        document.querySelector('.protocol-has-ind-form').style.display = 'block';
      } else {
        document.querySelector('.protocol-has-ind-form').style.display = 'none';
      }
      if (document.querySelector('#protocol_study_agent_3').checked) {
        document.querySelector('.protocol-has-ide-form').style.display = 'block';
      } else {
        document.querySelector('.protocol-has-ide-form').style.display = 'none';
      }
    }
    checkboxes.forEach((checkbox) => checkbox.addEventListener('change', () => checkGet()));
    checkGet();
  }

  // protocol show
  const uploadField = document.querySelector('.upload-field');
  if (uploadField) {
    function checkFile() {
      if (uploadField.value) {
        document.querySelector('.upload-button').disabled = '';
      } else {
        document.querySelector('.upload-button').disabled = true;
      }
    }
    uploadField.addEventListener('change', () => checkFile());
    checkFile();
  }

  // contents
  const toUnderReviewButton = document.querySelector('.to-under-review');
  if (toUnderReviewButton) {
    toUnderReviewButton.addEventListener('click', () => {
      const hasReviewerData = document.querySelector('.content-has-reviewer').dataset;
      if (hasReviewerData.hasReviewer === 'false') window.alert(hasReviewerData.message);
    });
  }

  const commentButton = document.querySelector('.comment-button');
  if (commentButton) {
    const commentButtonData = JSON.parse(commentButton.dataset.button);
    const commentModalData = JSON.parse(commentButton.dataset.modal);
    ReactDOM.render(
      React.createElement(ShowCommentButton,
                         {
                           buttonData: commentButtonData,
                           modalData: commentModalData,
                           onCommentSubmitted: (json) =>
                             document.querySelector(`#section-${json.id}-comment-icon`).innerHTML = '<i class="fa fa-commenting mr-s">'
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

  const contentTabs = document.querySelector('.content-tabs');
  if (contentTabs) {
    const menuData = contentTabs.dataset;
    ReactDOM.render(
      React.createElement(ContentTabs,
                          {
                            sectionsText: menuData.sectionsText,
                            instructionsText: menuData.instructionsText,
                            exampleText: menuData.exampleText,
                            sections: '',
                            instructions: menuData.instructions,
                            example: menuData.example,
                            copyText: menuData.copyText,
                            copyConfirm: menuData.copyConfirm,
                            noSeq: menuData.noSeq,
                            contents: JSON.parse(menuData.contents)
                          },
                          null),
      contentTabs
    );
  }

  // participations
  const allSectionsCheckbox = document.querySelector('.check-all-sections');
  if (allSectionsCheckbox) {
    allSectionsCheckbox.addEventListener('click', () =>
      document.querySelectorAll('input[type=checkbox]').forEach((checkbox) => checkbox.checked = true)
    );
  }

  const roleForm = document.querySelector('#participation_role');
  if (roleForm) {
    function checkSections() {
      if (roleForm.value === roleForm.lastChild.value) {
        document.querySelector('.participation-sections').style.display = 'none';
      } else {
        document.querySelector('.participation-sections').style.display = 'block';
      }
    }
    roleForm.addEventListener('change', () => checkSections());
    checkSections();
  }
});

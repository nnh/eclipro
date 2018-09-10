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
import Header from './header'
import { ProtocolIndex } from './protocol'
import './content_show'

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
      React.createElement(
        ProtocolIndex,
        {
          placeholder: formData.placeholder,
          text: formData.text,
          url: formData.url,
          headers: formData.headers,
          buttons: formData.buttons
        },
        null
      ),
      protocolIndex
    );
  }

  // protocol form
  const sponsors = document.querySelector('#protocol_sponsors');
  if (sponsors) {
    function checkSponsor() {
      if (Array.from(sponsors.selectedOptions).includes(sponsors.lastChild)) {
        document.querySelector('.protocol-sponsor-other-form').style.display = 'block';
      } else {
        document.querySelector('.protocol-sponsor-other-form').style.display = 'none';
      }
    }
    sponsors.addEventListener('change', checkSponsor);
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
    checkboxes.forEach((checkbox) => checkbox.addEventListener('change', checkGet));
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
    uploadField.addEventListener('change', checkFile);
    checkFile();
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
    roleForm.addEventListener('change', checkSections);
    checkSections();
  }
});

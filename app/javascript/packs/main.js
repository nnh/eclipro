/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'es6-shim';

import Rails from 'rails-ujs';
Rails.start();

import React from 'react';
import ReactDOM from 'react-dom';
import Header from './header';
import { ProtocolIndex } from './protocol';
import './content_show';
import I18n from './i18n';

I18n.locale = document.body.dataset.locale;

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
          newProtocolUrl: headerData.newProtocolUrl,
          currentUser: headerData.currentUser,
          editUrl: headerData.editUrl,
          signOutUrl: headerData.signOutUrl,
          languageUrl: headerData.languageUrl,
          signInUrl: headerData.signInUrl
        },
        null
      ),
      header
    );
  }

  // protocol index
  const protocolIndex = document.querySelector('.protocol-index');
  if (protocolIndex) {
    ReactDOM.render(
      React.createElement(ProtocolIndex, { url: protocolIndex.dataset.url }, null),
      protocolIndex
    );
  }

  // protocol form
  function checkSponsor() {
    if (Array.from(sponsors.selectedOptions).includes(sponsors.lastChild)) {
      document.querySelector('.protocol-sponsor-other-form').style.display = 'block';
    } else {
      document.querySelector('.protocol-sponsor-other-form').style.display = 'none';
    }
  }
  const sponsors = document.querySelector('#protocol_sponsors');
  if (sponsors) {
    sponsors.addEventListener('change', checkSponsor);
    checkSponsor();
  }

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
  const checkboxes = document.querySelectorAll('.protocol-checkbox-form');
  if (checkboxes.length) {
    checkboxes.forEach((checkbox) => checkbox.addEventListener('change', checkGet));
    checkGet();
  }

  // protocol show
  function checkFile() {
    if (uploadField.value) {
      document.querySelector('.upload-button').disabled = '';
    } else {
      document.querySelector('.upload-button').disabled = true;
    }
  }
  const uploadField = document.querySelector('.upload-field');
  if (uploadField) {
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

  function checkSections() {
    if (roleForm.value === roleForm.lastChild.value) {
      document.querySelector('.participation-sections').style.display = 'none';
    } else {
      document.querySelector('.participation-sections').style.display = 'block';
    }
  }
  const roleForm = document.querySelector('#participation_role');
  if (roleForm) {
    roleForm.addEventListener('change', checkSections);
    checkSections();
  }
});

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

import $ from 'jquery'
import 'bootstrap-sass'

import Rails from 'rails-ujs'
Rails.start();

import './tiny_mce'
import { Protocols } from './protocols'
import { HistoryIndex, HistoryCompare } from './history'
import { CommentIndex, CommentForm } from './comments'

$(function() {
  // protocols
  $(document).on('click', '.clickable-tr', function(e) {
    window.location = $(e.target.parentElement).data('link');
  });
  $(document).on('click', '.clickable-tr .btn', function(e) {
    e.stopPropagation();
    return true;
  });

  function filtering() {
    $.ajax({
      url: $('.filter-form').data('url'),
      type: 'GET',
      dataType: 'json',
      data: {
        protocol_name_filter: $('.filter-form').val()
      }
    }).done(function(res) {
      let target = $('#protocols-table')
      ReactDOM.render(
        <Protocols data={res} headers={target.data('headers')} buttons={target.data('buttons')} />,
        document.querySelector('#protocols-table')
      );
    });
  }
  $('.filter-button').click(function() {
    filtering();
  });
  $('.filter-form').keypress(function(e) {
    if (e.keyCode == 13) filtering();
  });
  if ($('.filter-button').length > 0) {
    filtering();
  }

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

  // comments
  function resetForm() {
    $('.reply-form').each((i, element) => {
      ReactDOM.unmountComponentAtNode(element);
    });
    $('#new-comment-form').hide();
    $('#new-comment-form').children().val('')
    $('.comment-submit-button').prop('disabled', true);
    $('.add-comment-form').show();
  }

  function changeResolvedComment() {
    if ($('.show-resolved').is(':checked')) {
      $('.resolve-comment').show();
      $('.checkbox-text').text($('.resolve-message-params').data('hide-text'));
    } else {
      $('.resolve-comment').hide();
      $('.checkbox-text').text($('.resolve-message-params').data('show-text'));
    }
  }

  $(document).on('click', '.show-comments-button', function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done(function(res) {
      ReactDOM.render(
        <CommentIndex data={res} buttons={$('#comment-index').data('buttons')} />,
        document.querySelector('#comment-index')
      );
      let target = $('#new-comment-form')
      let data = {
        content_id: target.data('content-id'), current_user_id: target.data('current-user-id'),
        parent_id: null, url: target.data('url')
      }
      ReactDOM.render(
        <CommentForm data={data} buttons={target.data('buttons')} />,
        document.querySelector('#new-comment-form')
      );
      $('.comment-modal').modal('show');
      changeResolvedComment();
    });
  });

  $(document).on('click', '.add-comment-button', function() {
    resetForm();
    $('.add-comment-form').hide();
    $('#new-comment-form').show();
  })

  $(document).on('keyup', '.comment-form-body', function() {
    if ($(this).val().length > 0) {
      $($(this).siblings().children()[0]).prop('disabled', false);
    } else {
      $($(this).siblings().children()[0]).prop('disabled', true);
    }
  });

  $(document).on('click', '.comment-cancel-button', function() {
    resetForm();
  });

  $(document).on('click', '.comment-submit-button', function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'POST',
      dataType: 'json',
      data: {
        comment: {
          body: $(this).parent().siblings().val(),
          content_id: $(this).data('content-id'),
          user_id: $(this).data('user-id'),
          parent_id: $(this).data('parent-id')
        }
      }
    }).done(function(res) {
      $(`#section-${res.no}-comment-icon`).html('<i class="fa fa-commenting mr-s">');
      $('.show-comments-button').html(`${$('.show-comments-button').data('text')} (${res.count})`);
      ReactDOM.render(
        <CommentIndex data={res.comments} buttons={$('#comment-index').data('buttons')} />,
        document.querySelector('#comment-index')
      );
      resetForm();
      changeResolvedComment();
    });
  });

  $(document).on('change', '.show-resolved', function() {
    changeResolvedComment();
  });

  $(document).on('click', '.reply-button', function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'GET',
      dataType: 'json',
      data: {
        comment: {
          parent_id: $(this).data('parent-id'),
        }
      }
    }).done(function(res) {
      resetForm();
      ReactDOM.render(
        <CommentForm data={res} buttons={$('#new-comment-form ').data('buttons')} />,
        document.querySelector(`#reply-${res.parent_id}`)
      );
    });
  });

  $(document).on('click', '.resolve-button', function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'PUT',
      dataType: 'json',
      data: {
        comment: {
          resolve: true,
        }
      }
    }).done(function(res) {
      ReactDOM.render(
        <CommentIndex data={res} buttons={$('#comment-index').data('buttons')} />,
        document.querySelector('#comment-index')
      );
      resetForm();
      changeResolvedComment();
    });
  });

  // history
  $('.history-button').click(function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done(function(res) {
      let target = $('#history-index');
      ReactDOM.render(
        <HistoryIndex data={res} headers={target.data('headers')} buttons={target.data('buttons')} />,
        document.querySelector('#history-index')
      );
      $('.history-modal').modal('show');
    });
  });

  $(document).on('click', '.compare-button', function() {
    $.ajax({
      url: $(this).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done(function(res) {
      ReactDOM.render(
        <HistoryCompare data={res.data} text={$('#history-compare').data('text')}/>,
        document.querySelector('#history-compare')
      );
      $('#history-index').hide();
    });
  });

  $(document).on('click', '.history-compare-back', function() {
    ReactDOM.unmountComponentAtNode(document.querySelector('#history-compare'));
    $('#history-index').show();
  });

  $('.history-revert').on('confirm:complete', function(e, answer) {
    if (answer) {
      $('.history-modal').modal('hide');
    }
  });
});

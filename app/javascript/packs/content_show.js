import React from 'react'
import ReactDOM from 'react-dom'
import { ShowCommentButton } from './comment'
import { ShowHistoryButton } from './history'
import ContentTabs from './content_tabs'
import EcliproTinyMCE from './tiny_mce'

document.addEventListener('DOMContentLoaded', () => {
  const contentTabsElm = document.querySelector('.content-tabs');
  if (contentTabsElm) {
    const dataset = document.querySelector('.tiny-mce-params') ? document.querySelector('.tiny-mce-params').dataset : undefined;
    const ecliproTinyMCE = dataset ? new EcliproTinyMCE(dataset) : undefined;

    const menuData = contentTabsElm.dataset;
    const contents = JSON.parse(menuData.contents);
    const contentTabs = ReactDOM.render(
      React.createElement(
        ContentTabs,
        {
          sectionsText: menuData.sectionsText,
          instructionsText: menuData.instructionsText,
          exampleText: menuData.exampleText,
          instructions: menuData.instructions,
          example: menuData.example,
          copyText: menuData.copyText,
          copyConfirm: menuData.copyConfirm,
          noSeq: menuData.noSeq,
          editable: menuData.editable,
          contents: contents,
          onCopy: (e) => { if (ecliproTinyMCE) ecliproTinyMCE.setContent(menuData.example); }
        },
        null
      ),
      contentTabsElm
    );

    const toUnderReviewButton = document.querySelector('.to-under-review');
    if (toUnderReviewButton) {
      toUnderReviewButton.addEventListener('click', () => {
        const hasReviewerData = document.querySelector('.content-has-reviewer').dataset;
        if (hasReviewerData.hasReviewer === 'false') window.alert(hasReviewerData.message);
      });
    }

    const commentButton = document.querySelector('.comment-button');
    if (commentButton) {
      const commentButtonData = commentButton.dataset;
      ReactDOM.render(
        React.createElement(
          ShowCommentButton,
          {
            count: commentButtonData.count,
            contentId: commentButtonData.contentId,
            currentUserId: commentButtonData.currentUserId,
            url: commentButtonData.url,
            onCommentSubmitted: (json) => {
              const c = contents.find(e => e.no_seq === json.no_seq);
              c.comments_count = json.count;
              contentTabs.setState({ contents: contents });
            }
          },
          null
        ),
        commentButton
      );
    }

    const historyButton = document.querySelector('.history-button');
    if (historyButton) {
      const historyModalData = JSON.parse(historyButton.dataset.modal);
      ReactDOM.render(
        React.createElement(
          ShowHistoryButton,
          { text: historyButton.dataset.text, modalData: historyModalData },
          null
        ),
        historyButton
      );
    }

    const submitButton = document.querySelector('.content-submit-button');
    if (submitButton) {
      const event = (e) => { if (ecliproTinyMCE.getTextIsChanged()) e.returnValue = ''; };
      submitButton.addEventListener('click', () => window.removeEventListener('beforeunload', event));
      window.addEventListener('beforeunload', event);
    }
  }
});

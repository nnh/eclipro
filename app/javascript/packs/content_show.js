import React from 'react';
import ReactDOM from 'react-dom';
import { ShowCommentButton } from './comment';
import { ShowHistoryButton } from './history';
import ContentTabs from './content_tabs';
import EcliproTinyMCE from './tiny_mce';

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
          instructions: menuData.instructions,
          example: menuData.example,
          noSeq: menuData.noSeq,
          editable: menuData.editable,
          contents,
          onCopy: () => ecliproTinyMCE && ecliproTinyMCE.setContent(menuData.example)
        },
        null
      ),
      contentTabsElm
    );

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
              contentTabs.setState({ contents });
            }
          },
          null
        ),
        commentButton
      );
    }

    const historyButton = document.querySelector('.history-button');
    if (historyButton) {
      ReactDOM.render(
        React.createElement(ShowHistoryButton, { url: historyButton.dataset.url }, null),
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

import tinyMCE from 'tinymce'
import 'tinymce/themes/modern/theme'
import 'tinymce/plugins/advlist'
import 'tinymce/plugins/anchor'
import 'tinymce/plugins/charmap'
import 'tinymce/plugins/emoticons'
import 'tinymce/plugins/fullscreen'
import 'tinymce/plugins/hr'
import 'tinymce/plugins/image'
import 'tinymce/plugins/insertdatetime'
import 'tinymce/plugins/link'
import 'tinymce/plugins/lists'
import 'tinymce/plugins/media'
import 'tinymce/plugins/nonbreaking'
import 'tinymce/plugins/pagebreak'
import 'tinymce/plugins/paste'
import 'tinymce/plugins/preview'
import 'tinymce/plugins/print'
import 'tinymce/plugins/searchreplace'
import 'tinymce/plugins/table'
import 'tinymce/plugins/template'
import 'tinymce/plugins/textcolor'
import 'tinymce/plugins/toc'
import 'tinymce/plugins/visualblocks'
import 'tinymce/plugins/visualchars'
import { fetchWithXCSRF } from './custom_fetch'

require.context(
  'file-loader?name=[path][name].[ext]&context=node_modules/tinymce!tinymce/skins',
  true,
  /.*/
);

document.addEventListener('DOMContentLoaded', () => {
  let textIsChanged = false;

  if (document.querySelector('textarea.tinymce')) {
    const cssPath = `${(process.env.RAILS_ENV == 'test') ? '/packs-test' : '/packs'}/tiny_mce_style.css`;
    const dataset = document.querySelector('.tiny-mce-params').dataset;
    const createPath = `/protocols/${dataset.protocolId}/contents/${dataset.contentId}/images`;
    const pubmedUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi';

    tinyMCE.init({
      selector: 'textarea.tinymce',
      height: 300,
      theme_advanced_toolbar_location: 'top',
      theme_advanced_toolbar_align: 'left',
      theme_advanced_statusbar_location: 'bottom',
      theme_advanced_buttons3_add: ['tablecontrols', 'fullscreen'],
      automatic_uploads: true,
      content_css: cssPath,
      images_upload_handler: async (blobInfo, success, failure) => {
        const formData = new FormData();
        formData.append('file', blobInfo.blob(), blobInfo.filename());
        try {
          const json = await fetchWithXCSRF(createPath, {
            method: 'POST',
            headers: {
              'Accept': 'application/json'
            },
            body: formData
          });
          success(json.image.url);
        } catch(error) {
          failure(`The image upload failed.\n${error}`);
        }
      },
      plugins: 'print, paste, searchreplace, media, link, hr, anchor, pagebreak, insertdatetime, nonbreaking, template, toc,' +
               'visualchars, visualblocks, preview, table, fullscreen, lists, advlist, textcolor, emoticons, charmap image',
      toolbar: [
        'bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | fullscreen charmap',
        'image reference container blank'
      ],
      setup: (editor) => {
        editor.addButton('reference', {
          tooltip: 'Import Reference',
          icon: 'icon-book',
          onclick: () => {
            editor.windowManager.open({
              title: 'Import Reference',
              body: [
                {type: 'label', label: 'Import a citation from PubMed.'},
                {type: 'textbox', name: 'pubmed_id', label: 'Pubmed ID'}
              ],
              onsubmit: (e) => {
                fetch(`${pubmedUrl}?db=pubmed&retmode=xml&id=${e.data.pubmed_id}`, {
                }).then((response) => {
                  return response.text();
                }).then((text) => {
                  return new window.DOMParser().parseFromString(text, 'application/xml');
                }).then((data) => {
                  const error = data.getElementsByTagName('ERROR');
                  if (error.length) {
                    alert(`Failed to get the data.\n${error[0].innerHTML}`);
                    return;
                  }

                  const authorNames = [];
                  const authors = data.getElementsByTagName('AuthorList')[0].getElementsByTagName('Author');
                  for (let i = 0; i < authors.length; i++) {
                    const author = authors[i];

                    let lastName = '';
                    const lastNameData = author.getElementsByTagName('LastName')[0];
                    if (lastNameData) { lastName = lastNameData.innerHTML; }

                    let initials = '';
                    const initialsData = author.getElementsByTagName('Initials')[0];
                    if (initialsData) { initials = initialsData.innerHTML; }

                    authorNames.push([lastName, initials].filter((text) => text).join(' '));
                  }

                  let title = '';
                  const articleTitle = data.getElementsByTagName('ArticleTitle')[0];
                  if (articleTitle) { title = articleTitle.innerHTML; }

                  let journal = '';
                  const jornalData = data.getElementsByTagName('Journal')[0].getElementsByTagName('ISOAbbreviation')[0];
                  if (jornalData) { journal = jornalData.innerHTML; }

                  const date = ['Year', 'Month', 'Day'].map((m) => {
                    const d = data.getElementsByTagName('PubDate')[0].getElementsByTagName(m)[0];
                    if (d != undefined) return d.innerHTML;
                  }).filter((f) => f).join(' ');

                  let number = '';
                  const issue = data.getElementsByTagName('Issue')[0];
                  if (issue) { number = issue.innerHTML; }

                  let page = '';
                  const pagination = data.getElementsByTagName('Pagination')[0].getElementsByTagName('MedlinePgn')[0];
                  if (pagination) { page = pagination.innerHTML; }

                  let text = '';
                  const volume = data.getElementsByTagName('Volume')[0];
                  if (volume) { text = volume.innerHTML; }

                  if (number) { text += `(${number})`; }
                  if (page) { text += `:${page}.`; }

                  editor.insertContent(`${authorNames} ${title} ${journal}.${date};${text}`);
                }).catch((error) => {
                  alert(`Failed to get the data.\n${error}`);
                });
              }
            });
          }
        });
        editor.addButton('container', {
          tooltip: 'Insert container (red: Japanese, blue: English)',
          icon: 'icon-double-arrow',
          onclick: () => {
            editor.insertContent(
              `<div class="container" contenteditable='true'>
                <div class="ja"><p>&nbsp;</p></div>
                <div class="en"><p>&nbsp;</p></div>
                <div class="space"><p>&nbsp;</p></div>
              </div>`
            );
          }
        });
        editor.addButton('blank', {
          tooltip: 'Insert blank after selected container',
          icon: 'icon-arrow',
          onclick: () => {
            const div = document.createElement('div');
            div.classList.add('space');
            div.innerHTML = '<p>&nbsp;</p>';
            tinymce.get('form-tinymce').selection.getNode().closest('.container').append(div);
          }
        });
        editor.on('change', () => {
          textIsChanged = true;
        });
      }
    });
  }

  const submitButton = document.querySelector('.content-submit-button');
  if (submitButton) {
    const event = (e) => {
      if (textIsChanged) { e.returnValue = ''; }
    };
    submitButton.addEventListener('click', () => {
      window.removeEventListener('beforeunload', event);
    });
    window.addEventListener('beforeunload', event);
  }

  const copyButton = document.querySelector('.example-copy-button');
  if (copyButton) {
    copyButton.addEventListener('click', (e) => {
      if (window.confirm(copyButton.dataset.message)) {
        const data = `<div contenteditable="true">${e.target.parentElement.previousSibling.innerHTML}</div>`;
        tinyMCE.get('form-tinymce').setContent(data);
        textIsChanged = true;
      }
    });
  }
});

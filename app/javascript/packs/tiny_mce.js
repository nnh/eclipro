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
import getPubmedData from './get_pubmed_data'

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
              onsubmit: async (e) => {
                try {
                  const result = await getPubmedData(e.data.pubmed_id);
                  editor.insertContent(result);
                } catch (error) {
                  alert(`Failed to get the data.\n${error}`);
                }
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
            editor.selection.getNode().closest('.container').append(div);
          }
        });
        editor.on('change', () => textIsChanged = true);
        editor.addCommand('changeText', () => textIsChanged = true);
      }
    });
  }

  const submitButton = document.querySelector('.content-submit-button');
  if (submitButton) {
    const event = (e) => { if (textIsChanged) e.returnValue = ''; };
    submitButton.addEventListener('click', () => window.removeEventListener('beforeunload', event));
    window.addEventListener('beforeunload', event);
  }
});

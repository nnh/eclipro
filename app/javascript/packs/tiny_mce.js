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

require.context(
  'file-loader?name=[path][name].[ext]&context=node_modules/tinymce!tinymce/skins',
  true,
  /.*/
);

$(() => {
  let textIsChanged = false;
  const cssPath = `${(process.env.RAILS_ENV == 'test') ? '/packs-test' : '/packs'}/tiny_mce_style.css`;

  if ($('textarea.tinymce').length > 0) {
    const CREATE_URL = `/protocols/${$('.tiny-mce-params').data('protocol-id')}/contents/${$('.tiny-mce-params').data('content-id')}/images`;
    const PUBMED_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi';

    tinyMCE.init({
      selector: 'textarea.tinymce',
      height: 300,
      theme_advanced_toolbar_location: 'top',
      theme_advanced_toolbar_align: 'left',
      theme_advanced_statusbar_location: 'bottom',
      theme_advanced_buttons3_add: ['tablecontrols', 'fullscreen'],
      automatic_uploads: true,
      content_css: cssPath,
      images_upload_handler: (blobInfo, success, failure) => {
        const formData = new FormData();
        formData.append('file', blobInfo.blob(), blobInfo.filename());
        $.ajax({
          url: CREATE_URL,
          type: 'POST',
          dataType: 'json',
          data: formData,
          processData: false,
          contentType: false
        }).done((res) => {
          success(res.image.url);
        }).fail((XMLHttpRequest, textStatus, errorThrown) => {
          failure(`The image upload failed.\n${errorThrown}`);
        });
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
                $.ajax({
                  type: 'GET',
                  dataType: 'xml',
                  url: PUBMED_URL,
                  data: { db: 'pubmed', retmode: 'xml', id: e.data.pubmed_id },
                  success: (response) => {
                    const author_names = [];
                    const authors = $(response).find('AuthorList').children();
                    for (let i = 0; i < authors.length; i++) {
                      const author = authors[i];
                      const author_name = [$(author).find('LastName').text(), $(author).find('Initials').text()].join(' ');
                      author_names.push(author_name);
                    }
                    const title = $(response).find('ArticleTitle').text();
                    const journal = $(response).find('Journal > ISOAbbreviation').text();
                    const date = ['PubDate > Year', 'PubDate > Month', 'PubDate > Day'].map((m) => $(response).find(m).text()).filter((t) => t.length > 0).join(' ');
                    const number = $(response).find('Issue').text();
                    const page = $(response).find('Pagination > MedlinePgn').text();
                    let text = $(response).find('Volume').text();
                    if (number.length > 0) { text += `(${number})`; }
                    if (page.length > 0) { text += `:${page}.`; }
                    editor.insertContent(`${author_names} ${title} ${journal}.${date};${text}`);
                  },
                  error: (xhr, textStatus, errorThrown) => {
                    alert(`Failed to get the data.\n${errorThrown}`);
                  }
                });
              }
            });
          }
        });
        editor.addButton('container', {
          tooltip: 'Insert container (red: Japanese, blue: English)',
          icon: 'icon-double-arrow',
          onclick: function() {
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
            const node = editor.selection.getNode();
            $(node).closest('.container').append('<div class="space"><p>&nbsp;</p></div>');
          }
        });
        editor.on('change', () => {
          textIsChanged = true;
        });
      }
    });
  }

  $('input[type=submit]').on('click', () => {
    $(window).off('beforeunload');
  });
  $(window).on('beforeunload', () => {
    if (textIsChanged && $('.content-submit-button').length > 0) return '';
  });

  $('.example-copy-button').click((e) => {
    if (window.confirm($('.example-copy-button').data('message'))) {
      const data = '<div contenteditable="true">' + $(e.target).parent().prev().html() + '</div>';
      tinyMCE.get('form-tinymce').setContent(data);
      textIsChanged = true;
    }
  });
});

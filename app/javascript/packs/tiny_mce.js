const $ = require('jquery');
const tinyMCE = require('tinymce');
require('tinymce/themes/modern/theme');
require('tinymce/plugins/advlist');
require('tinymce/plugins/anchor');
require('tinymce/plugins/charmap');
require('tinymce/plugins/emoticons');
require('tinymce/plugins/fullscreen');
require('tinymce/plugins/hr');
require('tinymce/plugins/image');
require('tinymce/plugins/insertdatetime');
require('tinymce/plugins/link');
require('tinymce/plugins/lists');
require('tinymce/plugins/media');
require('tinymce/plugins/nonbreaking');
require('tinymce/plugins/pagebreak');
require('tinymce/plugins/paste');
require('tinymce/plugins/preview');
require('tinymce/plugins/print');
require('tinymce/plugins/searchreplace');
require('tinymce/plugins/table');
require('tinymce/plugins/template');
require('tinymce/plugins/textcolor');
require('tinymce/plugins/toc');
require('tinymce/plugins/visualblocks');
require('tinymce/plugins/visualchars');

require.context(
  'file-loader?name=[path][name].[ext]&context=node_modules/tinymce!tinymce/skins',
  true,
  /.*/
);

$(function() {
  let textIsChanged = false;

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
      images_upload_handler: function (blobInfo, success, failure) {
        const formData = new FormData();
        formData.append('file', blobInfo.blob(), blobInfo.filename());
        $.ajax({
          url: CREATE_URL,
          type: 'POST',
          dataType: 'json',
          data: formData,
          processData: false,
          contentType: false
        }).done(function(res) {
          success(res.image.url);
        }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
          failure(`The image upload failed.\n${errorThrown}`);
        });
      },
      plugins: 'print, paste, searchreplace, media, link, hr, anchor, pagebreak, insertdatetime, nonbreaking, template, toc,' +
               'visualchars, visualblocks, preview, table, fullscreen, lists, advlist, textcolor, emoticons, charmap image',
      toolbar: [
        'bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | fullscreen charmap',
        'image reference'
      ],
      setup: function(editor) {
        editor.addButton('reference', {
          tooltip: 'Import Reference',
          icon: 'icon-book',
          onclick: function() {
            editor.windowManager.open({
              title: 'Import Reference',
              body: [
                {type: 'label', label: 'Import a citation from PubMed.'},
                {type: 'textbox', name: 'pubmed_id', label: 'Pubmed ID'}
              ],
              onsubmit: function(e) {
                $.ajax({
                  type: 'GET',
                  dataType: 'xml',
                  url: PUBMED_URL,
                  data: { db: 'pubmed', retmode: 'xml', id: e.data.pubmed_id },
                  success: function(response) {
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
                  error: function(xhr, textStatus, errorThrown) {
                    alert(`Failed to get the data.\n${errorThrown}`);
                  }
                });
              }
            });
          }
        });
        editor.on('change', function() {
          textIsChanged = true;
        });
      }
    });
  }

  $('input[type=submit]').on('click', function() {
    $(window).off('beforeunload');
  });
  $(window).on('beforeunload', function() {
    if (textIsChanged && $('.content-submit-button').length > 0) return '';
  });

  $('.example-copy-button').click(function(e) {
    if (window.confirm($('.example-copy-button').data('message'))) {
      const data = '<div contenteditable="true">' + $(e.target).parent().prev().html() + '</div>';
      tinyMCE.get('form-tinymce').setContent(data);
      textIsChanged = true;
    }
  });
});

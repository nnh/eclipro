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

function initTinyMCE() {
  if (typeof tinyMCE != 'undefined') {
    var base_url = '/protocols/' + $('.tiny-mce-params').data('protocol-id') + '/contents/';
    tinyMCE.init({
      selector: 'textarea.tinymce',
      height: 300,
      theme_advanced_toolbar_location: 'top',
      theme_advanced_toolbar_align: 'left',
      theme_advanced_statusbar_location: 'bottom',
      theme_advanced_buttons3_add: ['tablecontrols', 'fullscreen'],
      automatic_uploads: true,
      images_upload_handler: function (blobInfo, success, failure) {
        var formData = new FormData();
        formData.append('file', blobInfo.blob(), blobInfo.filename());
        $.ajax({
          url: base_url + $('.tiny-mce-params').data('content-id') + '/images',
          type: 'POST',
          dataType: 'json',
          data: formData,
          processData: false,
          contentType: false
        }).done(function(res) {
          success(res.image.url);
        }).fail(function(XMLHttpRequest, textStatus, errorThrown) {
          alert('The image upload failed.');
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
                  url: 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi',
                  data: { db: 'pubmed', retmode: 'xml', id: e.data.pubmed_id },
                  success: function(response) {
                    var author_names = [];
                    var authors = $(response).find('AuthorList').children();
                    for (var i = 0; i < authors.length; i++) {
                      var author = authors[i];
                      var author_name = [$(author).find('LastName').text(), $(author).find('Initials').text()].join(' ');
                      author_names.push(author_name);
                    }
                    var title = $(response).find('ArticleTitle').text();
                    var journal = $(response).find('Journal > ISOAbbreviation').text();
                    var month = $(response).find('PubDate > Month').text();
                    var day = $(response).find('PubDate > Day').text();
                    var date = $(response).find('PubDate > Year').text();
                    if (month.length > 0) { date += ' ' + month; }
                    if (day.length > 0) { date += ' ' + day; }
                    var number = $(response).find('Issue').text();
                    var page = $(response).find('Pagination > MedlinePgn').text();
                    var text = $(response).find('Volume').text();;
                    if (number.length > 0) { text += '(' + number + ')'; }
                    if (page.length > 0) { text += ':' + page + '.'; }
                    editor.insertContent(author_names + ' ' + title + ' ' + journal + '. ' + date + ';' + text);
                  },
                  error: function(xhr, textStatus, errorThrown) {
                    alert('Failed to get the data.');
                  }
                });
              }
            });
          }
        });
        editor.on('change', function() {
          require('./share').editorTextIsChanged = true;
        });
      }
    });
  } else {
    setTimeout(initTinyMCE(), 50);
  }
}

$(function() {
  if ($('textarea.tinymce').length > 0) {
    initTinyMCE();
  }
});

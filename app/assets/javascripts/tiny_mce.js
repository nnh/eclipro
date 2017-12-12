function initTinyMCE(selector) {
  if (typeof tinyMCE != 'undefined') {
    tinyMCE.init({
      selector: selector,
      height: 300,
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left",
      theme_advanced_statusbar_location: "bottom",
      theme_advanced_buttons3_add: ["tablecontrols","fullscreen"],
      uploadimage_form_url: '/protocols/' + $('.tiny-mce-params').data('protocol-id') +
                            '/contents/' + $('.tiny-mce-params').data('content-id') + '/images.json',
      plugins: "print, paste, searchreplace, media, link, hr, anchor, pagebreak, insertdatetime, nonbreaking, template, toc," +
               "visualchars, visualblocks, preview, table, fullscreen, lists, advlist, textcolor, emoticons, charmap, uploadimage",
      toolbar: [
        "bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | fullscreen charmap",
        "uploadimage reference"
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
                    toastr['error']('Failed to get the data.');
                  }
                });
              }
            });
          }
        });
      }
    });
  } else {
    setTimeout(initTinyMCE(selector), 50);
  }
}

$(function() {
  initTinyMCE("textarea.tinymce");
});

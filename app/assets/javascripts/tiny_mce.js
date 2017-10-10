function initTinyMCE(selector) {
  if (typeof tinyMCE != 'undefined') {
    tinyMCE.init({
      selector: selector,
      height: 300,
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left",
      theme_advanced_statusbar_location: "bottom",
      theme_advanced_buttons3_add: ["tablecontrols","fullscreen"],
      plugins: "print, paste, searchreplace, media, link, hr, anchor, pagebreak, insertdatetime, nonbreaking, template, toc," +
               "visualchars, visualblocks, preview, table, fullscreen, lists, advlist, textcolor, emoticons, charmap, uploadimage",
      toolbar: [
        "bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | forecolor backcolor emoticons | fullscreen charmap",
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
                  success: (response) => {
                    let author_names = []
                    let authors = $(response).find('AuthorList').children();
                    for (let i = 0; i < authors.length; i++) {
                      let author = authors[i];
                      let author_name = [$(author).find('LastName').text(), $(author).find('Initials').text()].join(' ');
                      author_names.push(author_name);
                    }
                    let title = $(response).find('ArticleTitle').text();
                    let journal = $(response).find('Journal > ISOAbbreviation').text();
                    let month = $(response).find('PubDate > Month').text();
                    let day = $(response).find('PubDate > Day').text();
                    let date = $(response).find('PubDate > Year').text();
                    if (month.length > 0) { date += ' ' + month; }
                    if (day.length > 0) { date += ' ' + day; }
                    let number = $(response).find('Issue').text();
                    let page = $(response).find('Pagination > MedlinePgn').text();
                    let text = $(response).find('Volume').text();;
                    if (number.length > 0) { text += '(' + number + ')'; }
                    if (page.length > 0) { text += ':' + page + '.'; }
                    editor.insertContent(author_names + ' ' + title + ' ' + journal + '. ' + date + ';' + text);
                  },
                  error: (xhr, textStatus, errorThrown) => {
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

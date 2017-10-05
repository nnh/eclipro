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
               "visualchars, visualblocks, preview, table, fullscreen, lists, advlist, textcolor, emoticons, charmap, image",
      toolbar: [
        "bold italic underline | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | forecolor backcolor emoticons | fullscreen charmap",
        "image reference"
      ],
      setup: function(editor) {
        editor.addButton('reference', {
          tooltip: 'Import Reference',
          icon: 'icon-book',
          onclick: function() {
            editor.insertContent('<div>test</div>');
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

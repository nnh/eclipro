$(function() {
  function initTinyMCE() {
    if (typeof tinyMCE != 'undefined') {
      tinyMCE.init({
        selector: "textarea.tinymce",
        height: 300,
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left",
        theme_advanced_statusbar_location: "bottom",
        theme_advanced_buttons3_add: ["tablecontrols","fullscreen"],
        plugins: "table, fullscreen, lists, advlist, textcolor, emoticons, charmap, image",
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
      setTimeout(initTinyMCE, 50);
    }
  }
  initTinyMCE();
});

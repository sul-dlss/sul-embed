// Class injects css into head of embeded page
    
export default class CssInjection {
  constructor() {
    this.themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme");
    this.fontIconsHtml = '<link href="https://sul-cdn.stanford.edu/sul_s' +
          'tyles/0.5.1/sul-icons.min.css" rel="stylesheet">';
  }

  appendToHead() {
    if ( this.themeUrl ) {
      const htmlSnippet = `<link rel="stylesheet" href="${this.themeUrl}" type="text/css" />`;
      $("head").append(htmlSnippet);
    }
  }

  injectFontIcons() {
    $('head').append(this.fontIconsHtml);
  }
}

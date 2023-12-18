// This draws thumbnails in the content list of the companion window component
export default class {
  constructor({isStanfordOnly, thumbnailUrl, defaultIcon, isLocationRestricted, fileLabel}) {
    this.isStanfordOnly = isStanfordOnly
    this.thumbnailUrl = thumbnailUrl
    this.defaultIcon = defaultIcon
    this.isLocationRestricted = isLocationRestricted
    this.fileLabel = fileLabel
  }

  build(index) {
    const activeClass = index === 0 ? 'active' : ''
    let labelClass = 'text'
    let stanfordOnlyScreenreaderText = ''
    if (this.isStanfordOnly) {
      labelClass += ' sul-embed-thumb-stanford-only';
      stanfordOnlyScreenreaderText = '<span class="visually-hidden">Stanford only</span>'
    }

    let thumbnailIcon = '';
    if (this.thumbnailUrl) {
      thumbnailIcon = `<img class="square-icon" src="${this.thumbnailUrl}" alt="" />`
    } else {
      thumbnailIcon = `<i class="${this.defaultIcon} default-thumbnail-icon"></i>`
    }

    let restrictedTextMarkup = ''
    let maxFileLabelLength = 45;
    if(this.isLocationRestricted) {
      const restrictedText = '(Restricted)'
      restrictedTextMarkup = `<span class="sul-embed-location-restricted-text">${restrictedText}</span>`
      maxFileLabelLength -= restrictedText.length;
    }

    // Note: the "position: relative" is required for the stretched-link style.
    return `<li class="media-thumb ${activeClass}" data-controller="thumbnail" data-action="click->thumbnail#activate" data-thumbnail-index-param="${index}" style="position: relative;" aria-controls="main-display" role="tab">
        ${thumbnailIcon}
        <a class="stretched-link" href="#">
          <span class="${labelClass}">
            ${stanfordOnlyScreenreaderText}${restrictedTextMarkup}
            ${this.truncateWithEllipsis(this.fileLabel, maxFileLabelLength)}
          </span>
        </a>
      </li>`
  }

  truncateWithEllipsis(text, maxLen) {
    return text.substr(0, maxLen - 1) + (text.length > maxLen ? '&hellip;' : '');
  }
}

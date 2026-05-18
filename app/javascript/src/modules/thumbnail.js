// This draws thumbnails in the content list of the companion window component
// Called by media_tag_controller.js
export default class {
  constructor({fileUri, isStanfordOnly, thumbnailUrl, defaultIcon, isLocationRestricted, fileLabel}) {
    this.fileUri = fileUri
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
      labelClass += ' sul-embed-thumb-stanford-only'
      stanfordOnlyScreenreaderText = '<span class="visually-hidden">Stanford only</span>'
    }

    let thumbnailIcon = ''
    if (this.thumbnailUrl) {
      thumbnailIcon = `<img data-controller="image" data-action="error->image#handleError auth-success@window->image#updateImage" class="square-icon" src="${this.thumbnailUrl}" alt="" />`
    } else {
      thumbnailIcon = `<i class="${this.defaultIcon} default-thumbnail-icon"></i>`
    }

    let restrictedTextMarkup = ''
    let maxFileLabelLength = 45
    if(this.isLocationRestricted) {
      const restrictedText = '(Restricted)'
      restrictedTextMarkup = `<span class="sul-embed-location-restricted-text">${restrictedText}</span>`
      maxFileLabelLength -= restrictedText.length
    }

    return `<li class="media-thumb ${activeClass}" data-action="click->content-list#showMedia keydown.enter->content-list#showMedia"
                data-content-list-target="listItem" data-content-list-index-param="${index}"
                data-url="${this.fileUri}"
                aria-controls="main-display" role="tab" tabindex="0">
        ${thumbnailIcon}
        <span class="${labelClass} su-underline">
          ${stanfordOnlyScreenreaderText}${restrictedTextMarkup}
          <span class="label-text">${this.truncateWithEllipsis(this.fileLabel, maxFileLabelLength)}</span>
        </span>
      </li>`
  }

  truncateWithEllipsis(text, maxLen) {
    return text.substr(0, maxLen - 1) + (text.length > maxLen ? '&hellip;' : '')
  }
}

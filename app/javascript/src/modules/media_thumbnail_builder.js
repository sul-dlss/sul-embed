export default function(dataset, index, isAudio) {
    const cssClass = isAudio ? 'sul-i-file-music-1' : 'sul-i-file-video-3'
    const activeClass = index === 0 ? 'active' : ''
    let labelClass = 'sul-embed-thumb-label'
    const isStanfordRestricted = dataset.stanfordOnly === "true"
    let stanfordOnlyScreenreaderText = ''
    if (isStanfordRestricted) {
      labelClass += ' sul-embed-thumb-stanford-only';
      stanfordOnlyScreenreaderText = '<span class="sul-embed-text-hide">Stanford only</span>'
    }

    let thumbnailIcon = '';
    if (dataset.thumbnailUrl !== '') {
      thumbnailIcon = `<img class="sul-embed-media-square-icon" src="${dataset.thumbnailUrl}" />`
    } else {
      thumbnailIcon = `<i class="${cssClass}"></i>`
    }

    const isLocationRestricted = dataset.locationRestricted === "true"

    let restrictedTextMarkup = ''
    let maxFileLabelLength = 45;
    if(isLocationRestricted) {
      const restrictedText = '(Restricted)'
      restrictedTextMarkup = `<span class="sul-embed-location-restricted-text">${restrictedText}</span>`
      maxFileLabelLength -= restrictedText.length;
    }

    const fileLabel = dataset.fileLabel || '';
    const duration = dataset.duration || '';
    // Note: the "position: relative" is required for the stretched-link style.
    return `<li class="sul-embed-media-slider-thumb ${activeClass}" data-controller="thumbnail" data-action="click->thumbnail#activate" data-thumbnail-index-param="${index}" style="position: relative;">
        <a class="${labelClass} sul-embed-stretched-link" href="#">
          ${thumbnailIcon}
          <span class="text">
            ${stanfordOnlyScreenreaderText}${restrictedTextMarkup}
            ${truncateWithEllipsis(fileLabel, maxFileLabelLength)}
            ${durationMarkup(duration)}
          </span>
        </a>
      </li>`

}

function truncateWithEllipsis(text, maxLen) {
  return text.substr(0, maxLen - 1) + (text.length > maxLen ? '&hellip;' : '');
}

function durationMarkup(duration) {
  if(duration && duration.length > 0) {
    return ` (${duration})`
  } else {
    return '';
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleError(event) {
    event.target.classList.add('image-thumbnail-icon')
    event.target.classList.add('default-thumbnail-icon')
    const videoIndex = event.target.parentElement.dataset.contentListIndexParam;
    this.switchPosters(videoIndex)
  }

  switchPosters(index) {
    const videoElement = document.querySelector(`video[data-index="${index}"]`)
    const poster = videoElement.getAttribute('poster');
    const fallback_poster = videoElement.dataset.fallbackPoster;
    videoElement.setAttribute("poster", fallback_poster);
    videoElement.dataset.fallbackPoster = poster;
  }

  updateImage() {
    document.querySelectorAll('.image-thumbnail-icon').forEach(element => {
      element.classList.remove('image-thumbnail-icon', 'default-thumbnail-icon')
      element.src = `${element.src}?${new Date().getTime()}`;
    });
  }
}
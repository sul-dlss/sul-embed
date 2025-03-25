import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleError(event) {
    event.target.classList.add('image-thumbnail-icon')
    event.target.classList.add('default-thumbnail-icon')
  }

  updateImage() {
    document.querySelectorAll('.image-thumbnail-icon').forEach(element => {
      element.classList.remove('image-thumbnail-icon', 'default-thumbnail-icon')
      element.src = `${element.src}?${new Date().getTime()}`;
    });
  }
}
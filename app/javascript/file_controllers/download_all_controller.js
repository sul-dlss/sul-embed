import { Controller } from "@hotwired/stimulus"

// This controller ensures Download All button doesn't get clicked repeatedly. The first
// click on Download button will cause the button text to be changed to
// "Initializing download" and disabled, then the download will start.
//
// An <a> element is used to enclose the <button> because Chrome and
// Stanford's SingleSignOn don't seem to like creating <a> tags dynamically and
// then clicking on them--maybe this a security feature? So the first click
// will also replace the <a> element in the DOM with the <button> which will
// prevent further clicks on the <a> since it will no longer exist.

export default class extends Controller {
  download(event) {
    const el = event.target;
    if (el.localName == 'button') {
      el.disabled = true;
      el.innerText = " Initializing download...";

      // replace the anchor tag with the button to prevent further clicks
      const a = el.parentElement;
      a.replaceWith(el);
    }
  }
}

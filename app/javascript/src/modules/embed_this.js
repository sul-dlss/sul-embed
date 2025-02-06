// Module handles Embed This form interaction

const EmbedThis = {
  init: function() {
    const formContainers = document.querySelectorAll('.sul-embed-embed-this-form');
    formContainers.forEach(formContainer => {
      this.observeEmbedForm(formContainer);
    });
  },
  observeEmbedForm: function(formContainer) {
    const textarea = formContainer.querySelector('textarea');
    const inputs = formContainer.querySelectorAll('input[type="checkbox"], input[type="text"]');

    inputs.forEach(input => {
      input.addEventListener('change', () => {
        const checked = input.checked;
        const inputType = input.type;
        const srcMatch = textarea.value.match(/src="(\S+)"/);
        const src = srcMatch ? srcMatch[1] : null; // Handle cases where src might not be found
        const urlAttr = '&' + input.dataset.embedAttr + '=true';

        if (!src) {
          console.error("No src attribute found in textarea.");
          return;
        }


        if (inputType === 'checkbox') {
          if (checked) {
            textarea.value = textarea.value.replace(urlAttr, '');
          } else {
            textarea.value = textarea.value.replace(src, src + urlAttr);
          }
        } else {
          const oldParamRegex = new RegExp('&' + input.dataset.embedAttr + "=\\w+");
          const oldParamMatch = textarea.value.match(oldParamRegex);
          const oldParam = oldParamMatch ? oldParamMatch[0] : null;

          if (oldParam) {
            textarea.value = textarea.value.replace(oldParam, '&' + input.dataset.embedAttr + '=' + input.value);
          } else {
            textarea.value = textarea.value.replace(src, src + '&' + input.dataset.embedAttr + '=' + input.value);
          }
        }
      });
    });
  }
};

export default EmbedThis;

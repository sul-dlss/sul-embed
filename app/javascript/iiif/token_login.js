function receive_message(event) {
  data = event.data;
  let token, error;
  if (data.hasOwnProperty('accessToken')) {
    console.log("got data")
      token = data.accessToken;
  } else {
      console.error("unable to receive token", data)
  }
}

// tokenLogin('https://sul-stacks-stage.stanford.edu/iiif/auth/v2/token?messageId=1&origin=https://sul-purl-stage.stanford.edu')
export default function tokenLogin(url) {
  window.addEventListener("message", receive_message);

  const iframe = document.createElement('iframe')
  iframe.setAttribute('src', url)
  document.body.appendChild(iframe)
}

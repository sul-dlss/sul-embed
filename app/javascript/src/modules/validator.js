// Calls the passed in URL to validate the user has permission to use an item
export default function(url, tokenWriter) {
  return new Promise((resolve, reject) => {
    fetch(url, { credentials: 'include' })
      .then((data) => data.json())
      .then((authResponse) => {
        tokenWriter(authResponse.token)
        resolve({ authResponse })
      }).catch((error) => reject(error))
  })
}

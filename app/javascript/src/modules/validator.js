// Calls the passed in URL to validate the user has permission to use an item
export default function(url, successFn) {
  return new Promise((resolve, reject) => {
    fetch(url)
      .then((data) => data.json())
      .then((json) => {
        successFn(json.token)
        resolve(json)
      }).catch((error) => reject(error))
  })
}

export default function(mediaTag) {
  return function(token) {
    if(token === undefined) {
      return;
    }
    const sources = mediaTag.querySelectorAll('source')
    sources.forEach((source) => {
      const originalSrc = source.getAttribute('src')
  
      if(originalSrc.indexOf('stacks_token') < 0) {
        source.setAttribute('src', `${originalSrc}?stacks_token=${token}`)
      }
    })
  }
}
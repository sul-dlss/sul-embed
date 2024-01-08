// Helper functions for sending metrics to the SDR metrics API
// NOTE: ahoy.js is loaded globally in app/views/embed/_analytics.html.erb

// When the viewer is loaded for an object
export const trackView = () => {
  if (typeof ahoy !== "undefined") ahoy.trackView(eventParameters());
};

// Parameters common to all events we track
// Modify url/page to be the embed location instead of embed.stanford.edu
const eventParameters = () => {
  const { url, page } = getEmbedLocation();
  const druid = getDruid();

  return { url, page, druid };
};

// The druid of the embedded object currently being viewed
const getDruid = () => {
  const purlUrl = new URLSearchParams(window.location.search).get("url");
  if (purlUrl) {
    try {
      const path = new URL(purlUrl).pathname
      const match = path.match(/(\w{2}\d{3}\w{2}\d{4})/);
      if (match) return match[0];
    } catch (e) {
      return "";
    }
  }
};

// The page on which the viewer is currently embedded
const getEmbedLocation = () => {
  try {
    const embedUrl = new URL(document.referrer);
    return {
      url: embedUrl.toString(),
      page: embedUrl.pathname,
    };
  } catch (e) {
    return {
      url: "",
      page: "",
    };
  }
};

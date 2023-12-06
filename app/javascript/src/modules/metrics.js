// Helper functions for sending metrics to the SDR metrics API
// NOTE: ahoy.js is loaded globally in app/views/embed/_analytics.html.erb

// When the viewer is loaded for an object
export const trackView = () => {
  ahoy.trackView(eventParameters());
};

// Set up download tracking for any links with a download attribute
export const trackFileDownloads = () => {
  document.querySelectorAll('a[download]').forEach(link => {
    link.addEventListener('click', event => {
      const linkElement = event.target.closest('a');
      try {
        const downloadUrl = new URL(linkElement.href);
        const file = downloadUrl.pathname.split("/").pop();
        trackFileDownload(file);
      } catch (e) {
        return;
      }
    });
  });
}

// When an entire object is downloaded as a .zip file
export const trackObjectDownload = () => {
  ahoy.track("download", eventParameters());
};

// When a single file is downloaded from an object
export const trackFileDownload = (file) => {
  ahoy.track("download", { file, ...eventParameters() });
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
      return new URL(purlUrl).pathname.split("/")[1];
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

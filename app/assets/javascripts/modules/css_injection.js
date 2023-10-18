// Module injects css into head of embedded page

import $ from "jquery";

export const appendToHead = function () {
  const themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme");

  if (themeUrl) {
    const htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
    $("head").append(htmlSnippet);
  }
};

export const injectFontIcons = function () {
  const iconsUrl = $("[data-sul-icons]").data("sul-icons");

  if (iconsUrl) {
    const htmlSnippet = linkHtml.replace("{{stylesheetLink}}", iconsUrl);
    $("head").append(htmlSnippet);
  }
};

export const injectPluginStyles = function () {
  const linkHtml =
    '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />';
  const pluginStylesheets =
    $("[data-plugin-styles]").data("plugin-styles") || "";

  $.each(pluginStylesheets.split(","), function (index, stylesheet) {
    const htmlSnippet = linkHtml.replace("{{stylesheetLink}}", stylesheet);
    $("head").append(htmlSnippet);
  });
};

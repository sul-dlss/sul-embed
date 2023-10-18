const { generateWebpackConfig, merge } = require('shakapacker')
const webpack = require('webpack')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const options = {
  resolve: {
      fallback: {
        url: false
      }
  },
  module: {
    rules: [{ test: /\.hbs$/, loader: "handlebars-loader" }]
  },
  plugins: [
    new webpack.IgnorePlugin({
      resourceRegExp: /@blueprintjs\/(core|icons)/, // ignore optional UI framework dependencies
    }),
  ],
}

module.exports = merge({}, generateWebpackConfig(), options)
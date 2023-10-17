const { generateWebpackConfig, merge } = require('shakapacker')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const options = {
  resolve: {
      fallback: {
        url: false
      }
  },
  module: {
    rules: [{ test: /\.hbs$/, loader: "handlebars-loader" }]
  }
}

module.exports = merge({}, generateWebpackConfig(), options)

const { generateWebpackConfig, merge } = require('shakapacker')
const webpack = require('webpack')

const baseWebpackConfig = generateWebpackConfig()
const options = {
  resolve: {
      fallback: {
        url: false
      }
  },
  plugins: [
    new webpack.IgnorePlugin({
      resourceRegExp: /@blueprintjs\/(core|icons)/, // ignore optional UI framework dependencies
    }),
  ],
}

module.exports = merge({}, baseWebpackConfig, options)

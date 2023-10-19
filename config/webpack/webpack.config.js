const { generateWebpackConfig, merge } = require('shakapacker')
const webpack = require('webpack')
const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin');

const isDevelopment = process.env.NODE_ENV !== 'production';
const baseWebpackConfig = generateWebpackConfig()
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
if (baseWebpackConfig.devServer) {
  options.plugins.push(
    new ReactRefreshWebpackPlugin({
      overlay: {
        sockPort: baseWebpackConfig.devServer.port,
      },
    })
  )
}

module.exports = merge({}, baseWebpackConfig, options)
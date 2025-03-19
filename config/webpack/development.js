const { env, generateWebpackConfig, merge } = require('shakapacker')
const webpack = require('webpack')
const ReactRefreshWebpackPlugin = require('@pmmmwh/react-refresh-webpack-plugin')

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

if (env.runningWebpackDevServer) {
  options.plugins.push(
    new ReactRefreshWebpackPlugin({
      overlay: {
        sockPort: baseWebpackConfig.devServer.port,
      },
    })
  )
}

module.exports = merge({}, baseWebpackConfig, options)

const path = require('path');
const { environment } = require('@rails/webpacker')
const webpack = require('webpack');

environment.config.merge({
  resolve: {
    alias: {
      '@material-ui/core': path.resolve('./', 'node_modules', '@material-ui/core'),
      '@material-ui/styles': path.resolve('./', 'node_modules', '@material-ui/styles'),
      react: path.resolve('./', 'node_modules', 'react'),
      'react-dom': path.resolve('./', 'node_modules', 'react-dom'),
    }
  }
})

environment.splitChunks();

environment.plugins.prepend(
  // Plugin to only load english translations to reduce bundle size
  'NormalModuleReplacement',
  new webpack.NormalModuleReplacementPlugin(
    /locales\/((?!en).)*$/,
    (resource) => {
      resource.request = 'empty_translation.js'
    }
  )
)

module.exports = environment

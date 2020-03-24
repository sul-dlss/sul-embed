const path = require('path');
const { environment } = require('@rails/webpacker')

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

module.exports = environment

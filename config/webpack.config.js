var path = require('path');

module.exports = {
  entry: {
    your_platform_node_modules: path.resolve(__dirname, '..', 'app', 'javascripts', 'your_platform_node_modules.js')
  },
  output: {
    filename: '[name].pack.js',
    path: path.resolve(__dirname, '..', 'vendor', 'packs')
  }
};
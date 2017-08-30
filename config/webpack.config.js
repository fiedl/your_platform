var path = require('path');

module.exports = {
  entry: {
    your_platform_node_modules: path.resolve(__dirname, '..', 'app', 'javascripts', 'your_platform_node_modules.js')
  },
  entry: {
    vue_app: path.resolve(__dirname, '..', 'app', 'javascripts', 'VueApp.js')
  },
  output: {
    filename: '[name].pack.js',
    path: path.resolve(__dirname, '..', 'vendor', 'packs')
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          // other vue-loader options go here
        }
      },
      {
        test: /\.js$/,
        loader: 'babel-loader',
        exclude: /node_modules/
      },
    ]
  },
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
};
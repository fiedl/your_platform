var path = require('path');

module.exports = {
  entry: {
    your_platform_node_modules: path.resolve(__dirname, '..', 'app', 'vue', 'your_platform_node_modules.js'),
    vue_app: path.resolve(__dirname, '..', 'app', 'vue', 'VueApp.coffee')
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
          presets: ["es2015"]
        }
      },
      {
        test: /\.js$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        options: {
          presets: ['es2015'],
        }
      },
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        test: /\.erb$/,
        enforce: 'pre',
        exclude: /node_modules/,
        use: [{
          loader: 'rails-erb-loader',
          options: {
            runner: (/^win/.test(process.platform) ? 'ruby ' : '') + 'bin/rails runner'
          }
        }]
      }
    ]
  },
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  },
};
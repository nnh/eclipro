const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const path = require('path')

environment.plugins.append(
  'ExtractTextPlugin',
  new ExtractTextPlugin("[name].css")
)

module.exports = Object.assign({}, environment.toWebpackConfig(), {
  entry: {
    main: './app/javascript/packs/main.js',
    export: './app/javascript/packs/export.js',
    tiny_mce_style: './app/javascript/packs/tiny_mce_style.css'
  },
  output: {
    path: path.resolve(__dirname, '..', '..', 'public', 'packs'),
  },
  module: {
    rules: [
      {
        test: /\.(yml|yaml)$/,
        use: [
          { loader: require.resolve('json-loader') },
          { loader: require.resolve('yaml-loader') }
        ]
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      },
      {
        test: require.resolve('tinymce/tinymce'),
        loaders: [
          'imports-loader?this=>window',
          'exports-loader?window.tinymce'
        ]
      },
      {
        test: /tinymce\/(themes|plugins)\//,
        loader: 'imports-loader?this=>window'
      },
      {
        test: /tiny_mce_style.css/,
        exclude: /node_modules/,
        use: ExtractTextPlugin.extract({
          use: ['css-loader']
        })
      }
    ]
  },
  resolve: {
    extensions: ['.js', '.jsx']
  }
})

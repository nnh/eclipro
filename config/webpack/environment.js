const { environment } = require('@rails/webpacker')
const webpack = require('webpack')
const ExtractTextPlugin = require('extract-text-webpack-plugin')
const RailsTranslationsPlugin = require('rails-translations-webpack-plugin');
const path = require('path')

environment.plugins.append(
  'ExtractTextPlugin',
  new ExtractTextPlugin("[name].css")
)

environment.plugins.append(
  'RailsTranslationsPlugin',
  new RailsTranslationsPlugin({
    localesPath: path.resolve(__dirname, '../locales'),
    root: path.resolve(__dirname, '../../app/javascript/packs')
  })
)

module.exports = Object.assign({}, environment.toWebpackConfig(), {
  entry: {
    main: './app/javascript/packs/main.js',
    export: './app/javascript/packs/export.js',
    tiny_mce_style: './app/javascript/packs/tiny_mce_style.css'
  },
  module: {
    loaders: [
      {
        test    : /\.json$/,
        loader  : 'json-loader'
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

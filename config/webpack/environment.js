const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.set(
  'Provide',
  new webpack.ProvidePlugin({
    jQuery: 'jquery',
    $: 'jquery'
  })
)

environment.plugins.set(
  'Dedupe',
  new webpack.optimize.DedupePlugin()
)

module.exports = Object.assign({}, environment.toWebpackConfig(), {
  entry: {
    main: './app/javascript/packs/main.js',
    export: './app/javascript/packs/export.js'
  },
  module: {
    loaders: [
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
      }
    ]
  },
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery'
    },
    extensions: ['.js', '.jsx']
  }
})

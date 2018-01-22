const environment = require('./environment')

// module.exports = environment.toWebpackConfig()

module.exports = Object.assign({}, environment.toWebpackConfig(), {
  module: {
    loaders: [
      {
        test: require.resolve('tinymce/tinymce'),
        loaders: [
          'imports-loader?this=>window',
          'exports-loader?window.tinymce'
        ]
      },
      {
        test: /tinymce\/(themes|plugins)\//,
        loaders: [
          'imports-loader?this=>window'
        ]
      }
    ]
  }
})

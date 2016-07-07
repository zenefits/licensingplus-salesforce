//combine nodemon
var nodemon = require('nodemon');
nodemon({
  script: 'dev-server.js',
  ignore: ['components/*', 'src', 'app.js'],
  ext: 'js json ejs env'
});

nodemon.on('start', function () {
  console.log('App has started');
}).on('quit', function () {
  console.log('App has quit');
}).on('restart', function (files) {
  console.log('App restarted due to: ', files);
});

// webpack the app
var webpack = require('webpack');
var webpackConfig = require('./webpack.config');
var compiler = webpack(webpackConfig);
compiler.watch(300, _webpackComplete);


function _webpackComplete(err, stats) {
  if(err) {
    console.error(err);
    return;
  }
  var jsonStats = stats.toJson();
  if(jsonStats.errors.length > 0){
    console.error.apply(this, jsonStats.errors);
    return;
  }
  if(jsonStats.warnings.length > 0) {
    console.error.apply(this, jsonStats.warnings);
    return;
  }
}
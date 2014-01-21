gulp = require('gulp')
gutil = require('gulp-util')
watch = require('gulp-watch')
coffee = require('gulp-coffee')
bump = require('gulp-bump')
lint = require('gulp-coffeelint')
mocha = require('gulp-mocha')
exec = require('gulp-exec')
istanbul = require('gulp-istanbul')
clean = require('gulp-clean')
git = require('gulp-git')
size = require('gulp-size')
child_process = require('child_process')
es = require('event-stream')
webpack = require('webpack')
webpackConfig = require('./webpack.config')
specHelper = require('./spec/spec_helper.js')

gulp.task 'build', ['compile'], (callback) ->
  config = Object.create(webpackConfig)
  config.plugins = config.plugins.concat(
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.UglifyJsPlugin()
  )

  webpack(config).run (error, stats) ->
    throw new gutil.PluginError('webpack', error) if error
    gutil.log '[webpack]', stats.toString(colors: true)
    callback()

gulp.task 'lint', ->
  stream = gulp.src('./src/**/*.coffee')
    .pipe(lint())
    .pipe(lint.reporter())
  stream

gulp.task 'bump:patch', ->
  gulp.src(['./package.json', './bower.json'])
  .pipe(bump(type: 'patch'))
  .pipe(gulp.dest('./'))

gulp.task 'bump:minor', ->
  gulp.src(['./package.json', './bower.json'])
  .pipe(bump(type: 'minor'))
  .pipe(gulp.dest('./'))

gulp.task 'bump:major', ->
  gulp.src(['./package.json', './bower.json'])
  .pipe(bump(type: 'major'))
  .pipe(gulp.dest('./'))

gulp.task 'git:tag-release', ->
  pkg = Object.create(require('./package.json'))
  gulp.src('./')
    .pipe(git.tag(pkg.version, "Tag v#{pkg.version}"))

gulp.task 'git:add-commit', ->
  gulp.src('./**/*')
  .pipe(git.add())
  .pipe(git.commit('Release commit.'))

gulp.task 'develop', ->
  gulp.watch ['./src/**/*', './spec/**/*'], ->
    gulp.run('spec')

gulp.task 'spec', ['compile'], ->
  stream = gulp.src(['./compile/src/**/*.js'])
    .pipe(istanbul())
    .on('end', ->

      gulp.src(['./compile/spec/**/*_spec.js'])
        .pipe(mocha(
          ui: 'bdd'
          reporter: 'spec'
        ))
        .pipe(istanbul.writeReports())
    )
  stream

gulp.task 'check-coverage', ->
  gulp.src('./.coverage.json')
    .pipe(exec('istanbul check-coverage <%= file.path %>'))


gulp.task 'clean', ->
  stream = gulp.src('./compile', read: false)
    .pipe(clean())
  stream

gulp.task 'compile', ['lint'], ->
  es.concat(
    gulp.src('./src/**/*.coffee')
      .pipe(coffee())
      .pipe(gulp.dest('./compile/src'))
    gulp.src('./spec/**/*.coffee')
      .pipe(coffee())
      .pipe(gulp.dest('./compile/spec'))
  )

gulp.task 'stats', ->
  gulp.src('build/*.js')
    .pipe(size(showFiles: true))
    .pipe(gulp.dest('build'))

gulp.task 'default', ['spec']

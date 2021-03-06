gulp = require('gulp')
gutil = require('gulp-util')
watch = require('gulp-watch')
coffee = require('gulp-coffee')
coveralls = require('gulp-coveralls')
bump = require('gulp-bump')
lint = require('gulp-coffeelint')
mocha = require('gulp-mocha')
exec = require('gulp-exec')
istanbul = require('gulp-istanbul')
clean = require('gulp-clean')
git = require('gulp-git')
size = require('gulp-size')
sloc = require('gulp-sloc')
uglify = require('gulp-uglify')
rename = require("gulp-rename")
es = require('event-stream')
fs = require('fs')
webpack = require('webpack')
webpackConfig = require('./webpack.config')
specHelper = require('./spec/spec_helper.js')

gulp.task 'webpack', ['compile'], (callback) ->
  config = Object.create(webpackConfig)
  config.plugins = config.plugins.concat(
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin()
  )

  webpack(config).run (error, stats) ->
    throw new gutil.PluginError('webpack', error) if error
    gutil.log '[webpack]', stats.toString(colors: true)
    callback()

gulp.task 'build', ['webpack'], (callback) ->
  gulp.src('./main.js')
     .pipe(uglify())
     .pipe(rename("main.min.js"))
     .pipe(gulp.dest('./'))

gulp.task 'lint', ->
  gulp.src('./src/**/*.coffee')
      .pipe(lint())
      .pipe(lint.reporter())

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
  gulp.watch(['./src/**/*', './spec/**/*'], ->
    gulp.run('spec')
  ).on('error', ->
    gutil.log(arguments)
    gulp.run('develop')
  )

gulp.task 'spec', ['clean:coverage', 'compile'], ->
  stream = gulp.src(['./compile/src/**/*.js'])
    .pipe(istanbul())
    .on('end', ->
      gulp.src(['./compile/spec/**/*_spec.js'])
        .pipe(mocha(
          ui: 'bdd'
          reporter: 'spec'
        ))
        .pipe(istanbul.writeReports('./coverage'))
    )
  stream

gulp.task 'check-coverage', ->
  unless fs.existsSync('coverage/coverage-final.json')
    gutil.log(gutil.colors.red("coverage-final.json not found."))
    process.exit(1)

  stream = gulp.src('coverage/coverage-final.json', read: false)
    .pipe(exec(
      'istanbul check-coverage --statements <%= options.coverage.statements %> --branches <%= options.coverage.branches %> --functions <%= options.coverage.functions %> --lines <%= options.coverage.lines %>',
      silent: false
      coverage: require('./.coverage.json')
    ))
    .on('error', (errors) ->
      errors
        .toString()
        .split("\n")
        .filter((line) -> !line.indexOf("ERROR:"))
        .forEach (error) ->
          gutil.log(gutil.colors.red(error))
      process.exit(1)
    )
  stream

gulp.task 'coveralls', ->
  gulp.src('./coverage/**/lcov.info')
      .pipe(coveralls())

gulp.task 'clean', ->
  gulp.src('./compile', read: false)
      .pipe(clean())

gulp.task 'clean:coverage', ->
  gulp.src('./coverage', read: false)
      .pipe(clean())

gulp.task 'compile', ['lint'], ->
  es.concat(
    gulp.src('./src/**/*.coffee')
        .pipe(coffee(bare: true, sourceMap: true))
        .pipe(gulp.dest('./compile/src'))
    gulp.src('./spec/**/*.coffee')
        .pipe(coffee(bare: true, sourceMap: true))
        .pipe(gulp.dest('./compile/spec'))
  )

gulp.task 'size', ->
  gulp.src('build/*.js')
      .pipe(size(showFiles: true))

gulp.task 'sloc', ->
  gulp.src('./src/**/*.coffee')
      .pipe(sloc())

gulp.task 'default', ['spec']

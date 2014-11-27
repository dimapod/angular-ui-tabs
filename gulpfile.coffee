gulp        = require("gulp")
clean       = require("gulp-clean")
concat      = require("gulp-concat")
uglify      = require("gulp-uglify")
less        = require("gulp-less")
ngAnnotate  = require("gulp-ng-annotate")
plumber     = require("gulp-plumber")
runSequence = require("run-sequence")
minifyCSS   = require("gulp-minify-css")
karma       = require('gulp-karma')
rename      = require("gulp-rename")
ghPages     = require("gulp-gh-pages")


unitWatch = false

sources =
  less  : "src/styles/*.less"
  js    : "src/*.js"
  tests : "test/unit/*.coffee"

destinations =
  root  : "dist/"
  styles: "dist/styles"

gulp.task "clean", ->
  gulp.src(destinations.root, {read: false})
    .pipe clean()

gulp.task "build-css", ->
  gulp.src sources.less
    .pipe less()
    .pipe plumber()
    .pipe gulp.dest destinations.styles
    .pipe minifyCSS()
    .pipe rename({ extname: '.min.css'})
    .pipe gulp.dest destinations.styles

gulp.task "build-js", ->
  gulp.src sources.js
    .pipe ngAnnotate()
    .pipe concat "angular-tabs.js"
    .pipe gulp.dest destinations.root
    .pipe uglify()
    .pipe rename({ extname: '.min.js'})
    .pipe gulp.dest destinations.root

gulp.task "ghPages", ->
  gulp.src(['./dist/**/*', './bower_components/**/*', './examples/**/*', 'index.html'], {base: "."})
    .pipe ghPages({})

gulp.task "watch", ->
  gulp.watch sources.less, ["build-css"]
  gulp.watch sources.js, ["build-js"]


gulp.task "karma", ->
  console.log('@unitWatch', @unitWatch)
  gulp.src(["bower_components/angular/angular.js", "bower_components/angular-mocks/angular-mocks.js", sources.js, sources.tests])
    .pipe karma({
      configFile: 'test/karma.unit.js',
      action: if unitWatch then 'watch' else 'run'
    })
    .on 'error', (err) ->
      throw err

gulp.task "unit", ->
  unitWatch = true
  runSequence "karma"

gulp.task "deploy", ->
  runSequence "build", "ghPages"

gulp.task "build", (callback) ->
  runSequence "clean", ["build-css", "build-js"], "karma", callback

gulp.task "serve", ->
  runSequence "build", "watch"

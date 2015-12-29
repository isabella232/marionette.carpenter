module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    clean:
      src: ['build', 'dist']

    copy:

      css:
        src: 'build/marionette.carpenter.css'
        dest: 'dist/marionette.carpenter.css'

      js:
        expand: true
        nonull: false
        cwd: 'build/'
        src: ['marionette.carpenter.js', 'marionette.carpenter.require.js',]
        dest: 'dist/'

      # This makes me :-(, sass task doesn't parse css files so we generate a scss file.
      # The copy task also drops the . syntax i the copied file.
      cssAsScss:
        files: [
          expand:true
          cwd: 'bower_components'
          src: ['**/jquery.resizableColumns.css']
          dest: 'bower_components'
          filter: 'isFile'
          ext: '.resizableColumns.scss'
        ]

    coffee:
      source:
        options:
          sourceMap: false
          bare: true
        expand: true
        cwd: 'src/'
        src: ['**/**.coffee']
        dest: 'build/'
        ext: '.js'

      spec:
        options:
          sourceMap: false
        expand: true
        cwd: 'spec'
        src: ['**/**.coffee']
        dest: 'build/spec/'
        ext: '.js'

    eco:
      compile:
        options:
          amd: true
        expand: true
        cwd: 'src/templates/'
        src: ['*.eco']
        dest: 'build/templates/'
        ext: '.js'

    requirejs:
      build:
        options:
          almond: true
          baseUrl: "build/"
          name: "controllers/table_controller"
          include: ["controllers/table_controller"]
          out: "build/marionette.carpenter.js"
          optimize: "none"
          generateSourceMaps: false
          wrap:
            startFile: 'src/_start.js'
            endFile: 'src/_end.js'

      spec:
        options:
          almond: true
          baseUrl: "build/"
          include: [
            "spec/controllers/table_controller_spec.js"
            "spec/views/create_spec.js"
            "spec/views/control_bar_spec.js"
            "spec/views/row_spec.js"
            "spec/views/row_list_spec.js"
            "spec/views/paginator_spec.js"
            "spec/utilities/string_utils_spec.js"
          ]
          out: "build/spec/specs.js"
          optimize: "none"
          generateSourceMaps: true

    uglify:
      options:
        mangle: true
      dist:
        files:
          "dist/marionette.carpenter.min.js": "dist/marionette.carpenter.js"

    concat:

      # "Fix up" our specs to load everything synchronously
      spec:
        src: ["build/spec/specs.js", "build/spec/require_stub.js"]
        dest: "build/spec/specs.js"

      css:
        src: ["build/css/**.css"]
        dest: "dist/marionette.carpenter.css"

    watch:
      files: ['src/**/**.coffee', 'src/**/**.eco', 'spec/**/**.coffee']
      tasks: ['spec']

    jasmine:
      run:
        options:
          vendor: [
            'bower_components/jquery/dist/jquery.js'
            'bower_components/underscore/underscore.js'
            'bower_components/backbone/backbone.js'
            'bower_components/backbone.marionette/lib/backbone.marionette.js'
            'bower_components/backbone.radio/build/backbone.radio.js'
            'bower_components/cocktail/Cocktail.js'
            'bower_components/jasmine-set/jasmine-set.js'
            'bower_components/sinon/index.js'
          ]
          specs: ['build/spec/specs.js']
          summary: true

    sass:
      options:
        includePaths: [
          'bower_components/compass-mixins/lib'
          'bower_components/jquery-resizable-columns/dist'
        ]
        sourceMap: false
        style: 'compact'
        functions:
          'image-url($img)': (img) ->
            new require('node-sass').types.String('url("/' + img.getValue() + '")')
      build:
        expand: true
        flatten: true
        src: ['./src/sass/*.scss']
        dest: './build/css'
        ext: '.css'

    imageEmbed:
      dist:
        src: [ "./dist/marionette.carpenter.css" ]
        dest: "./dist/marionette.carpenter.css"
        options:
          baseDir: './assets'

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-eco')
  grunt.loadNpmTasks('grunt-contrib-jasmine')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-sass')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-eco')
  grunt.loadNpmTasks('grunt-requirejs')
  grunt.loadNpmTasks('grunt-image-embed')
  grunt.loadNpmTasks('grunt-contrib-uglify')

  grunt.registerTask('style', ['clean', 'copy:cssAsScss', 'sass'])
  grunt.registerTask('build', ['clean', 'style', 'coffee', 'eco', 'requirejs', 'concat', 'copy:js', 'copy:css', 'imageEmbed', 'uglify'])
  grunt.registerTask('spec',  ['build', 'jasmine'])
  grunt.registerTask('default', ['build'])

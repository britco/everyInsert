module.exports = (grunt) ->
	# Package
	# =======
	pkg = require './package.json'

	# Configuration
	# =============
	grunt.initConfig
		pkg: pkg
		coffee:
			dist:
				src:  ['src/*.coffee'],
				dest: '<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js'
		uglify:
			options:
				mangle: false
				compress: false
				beautify: true
				wrap: 'globals'
				preserveComments: 'some'
				banner: '''
				/*!
				 * everyInsert
				 * @author Paul Dufour
				 * @company Brit + Co
				 */

				 '''
			dist:
				src: ['<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js']
				dest: '<%= pkg.distDirectory %>/<%= pkg.name %>-<%= pkg.version %>.js'
		watch:
			files: ['src/*.coffee', 'src/**/*.coffee']
			tasks: ['coffee']

	# Dev / prod toggles
	if process.env['DEV'] is 'true'
		grunt.config.set('coffee.dist.dest', '<%= pkg.devDistDirectory %>/<%= pkg.name %>-latest.js')
		grunt.config.set('uglify.dist.dest', '<%= pkg.devDistDirectory %>/<%= pkg.name %>-<%= pkg.version %>.js')
	else
		grunt.config.set('concat.dist.dest', '<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js')
		grunt.config.set('uglify.dist.dest', '<%= pkg.distDirectory %>/<%= pkg.name %>-<%= pkg.version %>.js')

	# Dependencies
	# ============
	for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
		grunt.loadNpmTasks name

	# Tasks
	# =====
	grunt.registerTask 'build', ->
		# Build for release
		grunt.task.run 'coffee'

		if process.env?.DEV != 'true'
			grunt.task.run 'uglify'
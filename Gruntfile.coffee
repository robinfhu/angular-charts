module.exports = (grunt)->
	require('grunt-recurse')(grunt, __dirname)

	grunt.Config =
		jade:
			compile:
				files:
					'demo/index.html': ['demo/index.jade']

	grunt.registerTask 'default', 'Perform all code build tasks',
		['jade']

	grunt.finalize()
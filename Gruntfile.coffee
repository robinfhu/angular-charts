module.exports = (grunt)->
	require('grunt-recurse')(grunt, __dirname)

	grunt.Config =
		jade:
			compile:
				files:
					'demo/index.html': ['demo/index.jade']

		coffee:
            options:
                bare: false
            client:
                files:
                    'dist/angular-charts.js': ['src/directive.coffee']

		karma:
            client:
                options:
                    browsers: ['Chrome']
                    frameworks: ['mocha','sinon-chai']
                    reporters: [ 'spec', 'junit']
                    junitReporter:
                        outputFile: 'karma.xml'
                    singleRun: true
                    preprocessors:
                        'src/*.coffee': 'coffee'
                        'tools/*.coffee': 'coffee'
                    files: [
                        'bower_components/angular/angular.js'
                        'bower_components/angular-mocks/angular-mocks.js'
                        'tools/*.coffee'
                        'src/*.coffee'
                    ]

	grunt.registerTask 'default', 'Perform all code build tasks',
		['jade','karma:client','coffee:client']

	grunt.finalize()
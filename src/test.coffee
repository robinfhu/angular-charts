describe 'Angular-Chart Module', ->
	describe 'module', ->
		it 'should exist', ->
			angular.module('rh.angular-charts').should.have.property 'controller'

	describe 'line chart directive', ->
		beforeEach angular.mock.module 'rh.angular-charts'

		it 'should exist (and have svg tag)', ->
			element = render 'rh-line-chart'
			console.log element[0]

			should.exist element, 'element exists'

			svg = element[0].querySelector 'svg'

			should.exist svg, 'there is an <svg> tag'


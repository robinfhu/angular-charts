describe 'Angular-Chart Module', ->
	describe 'module', ->
		it 'should exist', ->
			angular.module('rh.angular-charts').should.have.property 'controller'

	describe 'line chart directive', ->
		beforeEach angular.mock.module 'rh.angular-charts'

		createElem = (data=[])->
			sampleScope = 
				line: [
					key: 'test'
					values: data
				]

				options: 
					getX: (d,i)-> i 
					getY: (d)-> d.y

			attrs = 
				'rh-data': 'line'
				'rh-options': 'options'

			element = render 'rh-line-chart', sampleScope, attrs

		it 'should exist (and have svg tag)', ->
			element = createElem()
			should.exist element, 'element exists'

			svg = element[0].querySelector 'svg'

			should.exist svg, 'there is an <svg> tag'

		it 'should have a <path> element', ->
			element = createElem()
			path = element[0].querySelector 'svg path'
			should.exist path, '<path> exists'

		it 'exposes `width` and `height` in scope. And `options`.', ->
			element = createElem()
			scope = element.isolateScope()

			should.exist scope, 'scope exists'
			should.exist scope.parentWidth
			should.exist scope.parentHeight

			scope.parentWidth.should.be.a 'number'

			should.exist scope.options, 'options exists'
			scope.options.should.have.property 'getX'

		it 'creates a very simple line', ->
			data = [
				x: 0
				y: 0
			,
				x: 1
				y: 1
			]
			element = createElem data

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			should.exist scope.data, 'scope should have data'
			scope.data.should.be.instanceof Array

			path = element[0].querySelector 'svg path'
			d = path.attributes.getNamedItem 'd'

			should.exist d, 'path has d='

			svgPathData = d.nodeValue

			svgPathData.should.equal 'M0,100L100,0'

		it 'creates a line with 5 points', ->
			data = [
				x: 0
				y: 0
			,
				x: 1
				y: 1
			,
				x: 2
				y: 0.5
			,
				x: 3
				y: 0.25
			,
				x: 4
				y: 0.4
			]
			element = createElem data

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			path = element[0].querySelector 'svg path'
			d = path.attributes.getNamedItem 'd'
			svgPathData = d.nodeValue

			svgPathData.should.equal 'M0,100L25,0L50,50L75,75L100,60'

		it 'creates a line with Y range of [0,2]', ->
			data = [
				x: 0
				y: 0
			,
				x: 1
				y: 2
			,
				x: 2
				y: 1
			]
			element = createElem data

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			path = element[0].querySelector 'svg path'
			d = path.attributes.getNamedItem 'd'
			svgPathData = d.nodeValue

			svgPathData.should.equal 'M0,100L50,0L100,50'


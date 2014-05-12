describe 'Angular-Chart Module', ->
	describe 'module', ->
		it 'should exist', ->
			angular.module('rh.angular-charts').should.have.property 'controller'

	describe 'line chart directive', ->
		beforeEach angular.mock.module 'rh.angular-charts'

		createElem = (data=[], options={})->
			sampleScope = 
				line: data

				options: 
					getX: (d,i)-> i 
					getY: (d)-> d.y
					margin:
						left: 0
						bottom: 0

			angular.extend sampleScope.options, options

			attrs = 
				'rh-data': 'line'
				'rh-options': 'options'

			element = render 'rh-line-chart', sampleScope, attrs

		getAttr = (elem, attr)->
			elem.attributes.getNamedItem(attr).nodeValue

		generate = (data=[])->
			data.map (d,i)=>
				x: i 
				y: d 

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
				key: 'test'
				values: generate [0,1]
			]

			element = createElem data

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			should.exist scope.data, 'scope should have data'
			scope.data.should.be.instanceof Array

			path = element[0].querySelector 'svg .rh-lines path'
			d = path.attributes.getNamedItem 'd'

			should.exist d, 'path has d='

			svgPathData = d.nodeValue

			svgPathData.should.equal 'M0,100L100,0'

		it 'creates a line with 5 points', ->
			data = [
				key: 'test'
				values: generate [0,1,0.5,0.25,0.4]
			]
 
			element = createElem data

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			path = element[0].querySelector 'svg .rh-lines path'
			d = path.attributes.getNamedItem 'd'
			svgPathData = d.nodeValue

			svgPathData.should.equal 'M0,100L25,0L50,50L75,75L100,60'

		defaultData = [
			key: 'test'
			values: generate [0,2,1]
		]

		it 'creates a line with Y range of [0,2]', -> 
			element = createElem defaultData

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			path = element[0].querySelector 'svg .rh-lines path'

			svgPathData = getAttr path, 'd'

			svgPathData.should.equal 'M0,100L50,0L100,50'

		it 'creates multiple line series`', ->
			data = [
				key: 'test 1'
				values: generate [10,20,30]
			,
				key: 'test 2'
				values: generate [5,10,15]
			,
				key: 'test 3'
				values: generate [1,1.5,1.7]
			]

			element = createElem data 
			scope = element.isolateScope()
			controller = element.controller 'rhLineChart'

			scope.parentWidth = 100
			scope.parentHeight = 100
			scope.$digest()

			controller.should.have.property 'xScale'
			controller.should.have.property 'yScale'

			lines = element[0].querySelectorAll '.rh-lines path'

			lines.should.have.length 3

			controller.yScale.domain().should.deep.equal [1,30]

		it 'creates horizontal+vertical axes lines', ->
			element = createElem defaultData

			scope = element.isolateScope()

			scope.parentWidth = 100
			scope.parentHeight = 100

			scope.$digest()

			axesGroup = element[0].querySelector '.rh-axes'

			should.exist axesGroup, 'axes group'
			xAxis = axesGroup.querySelector 'path.x-axis'

			should.exist xAxis, 'xAxis exists'

			pathData = getAttr xAxis, 'd'
			pathData.should.equal 'M0,100H100'

			yAxis = axesGroup.querySelector 'path.y-axis'

			should.exist yAxis, 'yAxis exists'

			pathData = getAttr yAxis, 'd'
			pathData.should.equal 'M0,0V100'

		it 'creates x and y tick marks', ->
			element = createElem defaultData

			scope = element.isolateScope()

			scope.parentWidth = 103
			scope.parentHeight = 103

			scope.$digest()

			axesTicks = element[0].querySelector '.rh-axes .ticks'

			should.exist axesTicks, 'axes ticks group'

			yTicks = axesTicks.querySelectorAll 'path.y-tick'

			yTicks.should.have.length.greaterThan 4
			pathData = getAttr yTicks[2],'d'

			pathData.should.match /M0,.+?H103/ 

			xTicks = axesTicks.querySelectorAll 'path.x-tick'

			xTicks.should.have.length.greaterThan 4
			pathData = getAttr xTicks[2],'d'

			pathData.should.match /M.+?,0V103/

		it 'creates y axis tick labels', ->
			element = createElem defaultData

			scope = element.isolateScope()

			scope.parentWidth = 103
			scope.parentHeight = 103

			scope.$digest()

			labels = element[0].querySelectorAll '.rh-axes .labels text.y-tick'

			labels.should.have.length.greaterThan 4

			getAttr(labels[2],'text-anchor').should.equal 'end'

			labels[0].innerHTML.should.contain '0'
			labels[1].innerHTML.should.contain '0.2'
		
			prev = null
			for b in labels
				y = parseInt getAttr b, 'y'
				y.should.be.a 'number'

				y.should.not.equal prev 
				prev = y

			getAttr(labels[3],'x').should.equal '-10'

		it 'creates x axis tick labels', ->
			element = createElem defaultData

			scope = element.isolateScope()

			scope.parentWidth = 103
			scope.parentHeight = 103

			scope.$digest()

			labels = element[0].querySelectorAll '.rh-axes .labels text.x-tick'

			labels.should.have.length.greaterThan 4

			getAttr(labels[2],'text-anchor').should.equal 'middle'

			y = parseInt getAttr(labels[2],'y')

			y.should.be.greaterThan 103 

			prev = null
			for b in labels
				x = parseInt getAttr b, 'x'
				x.should.be.a 'number'

				x.should.not.equal prev 
				prev = x


		it 'can create left and bottom margins', ->
			options = 
				margin:
					left: 90
					bottom: 90

			element = createElem defaultData, options

			scope = element.isolateScope()
			controller = element.controller 'rhLineChart'

			scope.parentWidth = 700
			scope.parentHeight = 500

			scope.$digest()

			wholeChart = element[0].querySelector 'svg .whole-chart'

			should.exist wholeChart, 'whole-chart exists'

			transform = getAttr wholeChart, 'transform'

			should.exist transform, 'transform= attribute'

			transform.should.contain 'translate(90,0)'

			controller.should.have.property 'realWidth'
			controller.should.have.property 'realHeight'

			controller.realWidth.should.equal (700-90)
			controller.realHeight.should.equal (500-90)

		it 'has a layer where you can mouseover and see a guideline', ->
			options = 
				margin:
					left: 10

			element = createElem defaultData, options

			scope = element.isolateScope()
			controller = element.controller 'rhLineChart'

			scope.parentWidth = 103
			scope.parentHeight = 103

			scope.$digest()

			layer = element[0].querySelector 'svg .whole-chart rect.interactive-layer'
			should.exist layer, 'interactive layer'

			getAttr(layer,'width').should.equal '93'
			getAttr(layer,'height').should.equal '103'

			controller.showGuideline true
			scope.$digest()

			line = element[0].querySelector '.whole-chart .guideline'
			should.exist line, 'guideline exists'

			controller.updateGuideline {offsetX: 60}
			scope.$digest()

			getAttr(line,'d').should.equal 'M46.5,0V103'

			circles = element[0].querySelectorAll '.interactives circle.highlight-point'
			circles.should.have.length 1

			controller.showGuideline false
			scope.$digest()
			line = element[0].querySelector '.whole-chart .guideline'
			should.not.exist line, 'guideline does not exists'

		it 'has highlight points when hovering over chart', ->
			data = [
				key: 'test 1'
				values: generate [1,2,3]
			,
				key: 'test 2'
				values: generate [6.7,6.8,6.9]
			,
				key: 'test 3'
				values: generate [3,6,9]
			]
			element = createElem data

			scope = element.isolateScope()
			controller = element.controller 'rhLineChart'

			scope.parentWidth = 103
			scope.parentHeight = 103
			controller.showGuideline true

			scope.$digest()

			controller.updateGuideline {offsetX: 60}
			scope.$digest()

			circles = element[0].querySelectorAll '.interactives circle.highlight-point'
			circles.should.have.length 3

			for circle in circles 
				getAttr(circle,'r').should.equal '5'
				should.exist getAttr(circle,'cx')
				should.exist getAttr(circle,'cy')


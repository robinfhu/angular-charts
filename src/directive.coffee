module = angular.module 'rh.angular-charts', []

class LineChartCtrl
	constructor: (@$scope, @interactiveBisect)->
		@pathData = ''
		@_displayGuideline = false
		@guidelinePath = 'M0,0'

		for attr in [
			'data'
			'parentWidth'
			'parentHeight'
		]
			$scope.$watch attr, => @chartUpdate()

	chartUpdate: ->
		return unless @sanityCheck()

		@computeArea()
		@computeScales()
		@computeLines()
		@computeAxes()

	sanityCheck: ->
		return false unless @$scope.data?
		return false if not angular.isArray @$scope.data
		return false if @$scope.data.length is 0

		return true

	computeArea: ->
		left = @$scope.options.margin.left || 0
		bottom = @$scope.options.margin.bottom || 0

		@realWidth = @$scope.parentWidth - left
		@realHeight = @$scope.parentHeight - bottom
		
		@marginTranslate = "translate(#{left},0)"

	computeScales: ->
		values = @$scope.data[0].values 
		opts = @$scope.options

		@xScale = d3.scale.linear()
		@yScale = d3.scale.linear()

		# Figure out min and max x-axis values
		xExtent = d3.extent values.map opts.getX 
		@xScale.domain(xExtent).range([0,@realWidth])
		
		###
		Figure out the maximum and minimum y-axis value
		from all data points
		###
		yValues = d3.merge @$scope.data.map(
			(d)-> d.values.map(opts.getY)
		) 

		yExtent = d3.extent yValues
		@yScale.domain(yExtent).range([@realHeight,0])

	computePath: (values)->
		###
		Given array of x,y pairs, Create <path> d= parameter. Like M0,100L100,0

		For each point, need to compute the exact pixel coordinate location in <svg>
		box.  That's why we use the xScale and yScale functions.
		###

		opts = @$scope.options

		points = []

		for v,i in values 
			x = @xScale opts.getX(v,i)
			y = @yScale opts.getY(v,i)

			points.push "#{x},#{y}"

		result = "M#{points.join('L')}"

	computeLines: ->
		###
		Loop through all series' and create a <path> definition
		for each line.
		###
		@lines = @$scope.data.map (d)=>
			@computePath d.values 

	computeAxes: ->
		###
		Compute x,y locations for the tick grid lines
		###
		yPosition = @yScale 0

		xTickLabels = @xScale.ticks().map (t)=>
			config =
				label: t 
				x: @xScale t

		xTicks = @xScale.ticks().map (t)=>
			xPos = @xScale t 
			"M#{xPos},0V#{@realHeight}"

		yTickLabels = @yScale.ticks().map (t)=>
			config =
				label: t
				y: @yScale t 

		yTicks = @yScale.ticks().map (t)=>
			yPos = @yScale t 
			"M0,#{yPos}H#{@realWidth}"

		@axis = {
			xPathData: "M0,#{yPosition}H#{@realWidth}"
			yPathData: "M0,0V#{@realHeight}"
			yTicks
			xTicks
			yTickLabels
			xTickLabels
		}

	updateGuideline: (evt)->
		xPixel = evt.offsetX - @$scope.options.margin.left
		xDomain = @xScale.invert xPixel

		result = @interactiveBisect @$scope.data[0].values, 
			xDomain,
			@$scope.options.getX 

		xPos = @xScale result
		 
		@guidelinePath = "M#{xPos},0V#{@realHeight}"

	showGuideline: (flag)->
		return @_displayGuideline unless flag?

		@_displayGuideline = flag

	strokeColor: (i)->
		d3.scale.category10().range()[i % 10]



module.controller LineChartCtrl.name, LineChartCtrl

module.directive 'rhLineChart', ($window)->
	restrict: 'EA'
	controller: LineChartCtrl.name
	controllerAs: 'ctrl'
	scope:
		data: '=rhData'
		options: '=rhOptions'
	template: """
	<svg>
		<g class='whole-chart rh-chart' ng-attr-transform={{ctrl.marginTranslate}}>
		    <g style='stroke: black;' class='rh-axes'>
				<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />
				<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />
				
				<g class='ticks' style='stroke: #ccc; stroke-width: 1px;'>
					<path class='y-tick' 
						ng-repeat='tick in ctrl.axis.yTicks track by $index' 
						ng-attr-d={{tick}} />

					<path class='x-tick' 
						ng-repeat='tick in ctrl.axis.xTicks track by $index' 
						ng-attr-d={{tick}} />
				</g>

				<g class='labels'>
					<text
						ng-repeat='label in ctrl.axis.yTickLabels' 
						ng-attr-y={{label.y}}
						x='-10'
						class='y-tick'
						stroke='none' 
						text-anchor='end'>

					{{label.label}}
					</text>

					<text
						ng-repeat='label in ctrl.axis.xTickLabels' 
						ng-attr-x={{label.x}}
						ng-attr-y={{ctrl.realHeight+10}}
						class='x-tick' 
						stroke='none'
						text-anchor='middle'>

					{{label.label}}
					</text>
				</g>
			</g>
			<g style='fill: none; stroke-width:1.5px' class='rh-lines'>
				<path ng-repeat='line in ctrl.lines track by $index' 
					ng-attr-d={{line}} 
					ng-attr-stroke={{ctrl.strokeColor($index)}} />
			</g>

			<path class='guideline' 
				stroke='#aaa'
				ng-attr-d={{ctrl.guidelinePath}} 
				ng-if='ctrl.showGuideline()' />

			<rect 
				class='interactive-layer' 
				ng-mouseenter='ctrl.showGuideline(true)'
				ng-mouseleave='ctrl.showGuideline(false)'
				ng-mousemove='ctrl.updateGuideline($event)'
				ng-attr-height={{ctrl.realHeight}}
				ng-attr-width={{ctrl.realWidth}} />
		</g>
	</svg>
	"""
	link: (scope, element, attrs, controller)->
		calcSize = ->
			domElem = element[0]
			scope.parentWidth = domElem.offsetWidth
			scope.parentHeight = domElem.offsetHeight

		calcSize()

		$window.onresize = ->
			scope.$apply ->
				calcSize()

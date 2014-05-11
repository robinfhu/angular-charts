module = angular.module 'rh.angular-charts', []

class LineChartCtrl
	constructor: (@$scope)->
		@pathData = ''

		for attr in [
			'data'
			'parentWidth'
			'parentHeight'
		]
			$scope.$watch attr, => 
				@computeArea()
				@computeScales()
				@computeLines()
				@computeAxes()

	computeArea: ->
		@realWidth = @$scope.parentWidth
		@realHeight = @$scope.parentHeight

	computeScales: ->
		values = @$scope.data[0].values 
		opts = @$scope.options

		@xScale = d3.scale.linear()
		@yScale = d3.scale.linear()

		xExtent = d3.extent values.map opts.getX 
		@xScale.domain(xExtent).range([0,@realWidth])
		
		yExtent = d3.extent values.map opts.getY
		@yScale.domain(yExtent).range([@realHeight,0])

	computePath: (values)->
		# Given data, Create <path> d= parameter. Like M0,100L100,0
		opts = @$scope.options

		points = []

		for v,i in values 
			x = @xScale opts.getX(v,i)
			y = @yScale opts.getY(v,i)

			points.push "#{x},#{y}"

		result = "M#{points.join('L')}"

	computeLines: ->
		@pathData = @computePath @$scope.data[0].values

	computeAxes: ->
		yPosition = @yScale 0

		yTicks = @xScale.ticks().map (t)=>
			xPos = @xScale t 
			"M#{xPos},0V#{@realHeight}"

		xTicks = @yScale.ticks().map (t)=>
			yPos = @yScale t 
			"M0,#{yPos}H#{@realWidth}"

		@axis = 
			xPathData: "M0,#{yPosition}H#{@realWidth}"
			yPathData: "M0,0V#{@realHeight}"
			yTicks: yTicks
			xTicks: xTicks



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
	    <g style='stroke: black; stroke-width: 2px;' class='rh-axes'>
			<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />
			<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />
			
			<g class='ticks' style='stroke: #ccc; stroke-width: 1px;'>
				<path class='y-tick' ng-repeat='tick in ctrl.axis.yTicks track by $index' ng-attr-d={{tick}} />
				<path class='x-tick' ng-repeat='tick in ctrl.axis.xTicks track by $index' ng-attr-d={{tick}} />
			</g>
		</g>
		<g style='stroke: red;fill: none; stroke-width:1.5px' class='rh-lines'>
			<path ng-attr-d={{ctrl.pathData}} />
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

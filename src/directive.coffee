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

		@axis = 
			xPathData: "M0,#{yPosition}H#{@realWidth}"
			yPathData: "M0,0V#{@realHeight}"



module.controller LineChartCtrl.name, LineChartCtrl

module.directive 'rhLineChart', ->
	restrict: 'EA'
	controller: LineChartCtrl.name
	controllerAs: 'ctrl'
	scope:
		data: '=rhData'
		options: '=rhOptions'
	template: """
	<svg>
		<g style='stroke: red;fill: none;' class='rh-lines'>
			<path ng-attr-d={{ctrl.pathData}} />
		</g>

		<g style='stroke: black; stroke-width: 2px;' class='rh-axes'>
			<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />
			<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />
			
			<g class='ticks'>
			</g>
		</g>
	</svg>
	"""
	link: (scope, element, attrs, controller)->
		domElem = element[0]
		scope.parentWidth = domElem.offsetWidth
		scope.parentHeight = domElem.offsetHeight

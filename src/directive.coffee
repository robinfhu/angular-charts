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
				@computeScales()
				@pathData = @computePath()

	computeScales: ->
		values = @$scope.data[0].values 
		opts = @$scope.options

		@xScale = d3.scale.linear()
		@yScale = d3.scale.linear()

		xExtent = d3.extent values.map opts.getX 
		@xScale.domain(xExtent).range([0,@$scope.parentWidth])
		
		yExtent = d3.extent values.map opts.getY
		@yScale.domain(yExtent).range([@$scope.parentHeight,0])

	computePath: ->
		# Given data, Create <path> d= parameter. Like M0,100L100,0
		values = @$scope.data[0].values 
		opts = @$scope.options

		points = []

		for v,i in values 
			x = @xScale opts.getX(v,i)
			y = @yScale opts.getY(v,i)
			
			points.push "#{x},#{y}"

		result = "M#{points.join('L')}"

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
		<g style='stroke: red;fill: none;'>
			<path ng-attr-d={{ctrl.pathData}} />
		</g>
	</svg>
	"""
	link: (scope, element, attrs, controller)->
		domElem = element[0]
		scope.parentWidth = domElem.offsetWidth
		scope.parentHeight = domElem.offsetHeight

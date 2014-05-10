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
				@pathData = @computePath()

	computePath: ->
		# Given data, Create <path> d= parameter. Like M0,100L100,0
		values = @$scope.data[0].values 

		points = []

		xScale = d3.scale.linear()
		yScale = d3.scale.linear()

		xScale.domain([0, values.length-1]).range([0,@$scope.parentWidth])
		yScale.domain([0, 1]).range([@$scope.parentHeight,0])
		for v in values 
			x = xScale v.x 
			y = yScale v.y 
			points.push "#{x},#{y}"


		result = "M#{points.join('L')}"

module.controller LineChartCtrl.name, LineChartCtrl

module.directive 'rhLineChart', ->
	restrict: 'EA'
	controller: LineChartCtrl.name
	controllerAs: 'ctrl'
	scope:
		data: '=rhData'
	template: """
	<svg>
		<g style='stroke: red'>
			<path ng-attr-d={{ctrl.pathData}} />
		</g>
	</svg>
	"""
	link: (scope, element, attrs, controller)->
		domElem = element[0]
		scope.parentWidth = domElem.offsetWidth
		scope.parentHeight = domElem.offsetHeight

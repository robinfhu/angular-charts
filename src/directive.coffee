module = angular.module 'rh.angular-charts', []

module.directive 'rhLineChart', ->
	restrict: 'EA'
	template: """
	<svg></svg>
	"""
	link: (scope, element, attrs)->

		
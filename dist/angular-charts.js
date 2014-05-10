(function() {
  var module;

  module = angular.module('rh.angular-charts', []);

  module.directive('rhLineChart', function() {
    return {
      restrict: 'EA',
      template: "<svg></svg>",
      link: function(scope, element, attrs) {}
    };
  });

}).call(this);

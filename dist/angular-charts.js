(function() {
  var LineChartCtrl, module;

  module = angular.module('rh.angular-charts', []);

  LineChartCtrl = (function() {
    function LineChartCtrl($scope) {
      var attr, _i, _len, _ref;
      this.$scope = $scope;
      this.pathData = '';
      _ref = ['data', 'parentWidth', 'parentHeight'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        $scope.$watch(attr, (function(_this) {
          return function() {
            return _this.pathData = _this.computePath();
          };
        })(this));
      }
    }

    LineChartCtrl.prototype.computePath = function() {
      var points, result, v, values, x, xScale, y, yScale, _i, _len;
      values = this.$scope.data[0].values;
      points = [];
      xScale = d3.scale.linear();
      yScale = d3.scale.linear();
      xScale.domain([0, values.length - 1]).range([0, this.$scope.parentWidth]);
      yScale.domain([0, 1]).range([this.$scope.parentHeight, 0]);
      for (_i = 0, _len = values.length; _i < _len; _i++) {
        v = values[_i];
        x = xScale(v.x);
        y = yScale(v.y);
        points.push("" + x + "," + y);
      }
      return result = "M" + (points.join('L'));
    };

    return LineChartCtrl;

  })();

  module.controller(LineChartCtrl.name, LineChartCtrl);

  module.directive('rhLineChart', function() {
    return {
      restrict: 'EA',
      controller: LineChartCtrl.name,
      controllerAs: 'ctrl',
      scope: {
        data: '=rhData'
      },
      template: "<svg>\n	<g style='stroke: red'>\n		<path ng-attr-d={{ctrl.pathData}} />\n	</g>\n</svg>",
      link: function(scope, element, attrs, controller) {
        var domElem;
        domElem = element[0];
        scope.parentWidth = domElem.offsetWidth;
        return scope.parentHeight = domElem.offsetHeight;
      }
    };
  });

}).call(this);

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
            _this.computeScales();
            return _this.pathData = _this.computePath();
          };
        })(this));
      }
    }

    LineChartCtrl.prototype.computeScales = function() {
      var opts, values, xExtent, yExtent;
      values = this.$scope.data[0].values;
      opts = this.$scope.options;
      this.xScale = d3.scale.linear();
      this.yScale = d3.scale.linear();
      xExtent = d3.extent(values.map(opts.getX));
      this.xScale.domain(xExtent).range([0, this.$scope.parentWidth]);
      yExtent = d3.extent(values.map(opts.getY));
      return this.yScale.domain(yExtent).range([this.$scope.parentHeight, 0]);
    };

    LineChartCtrl.prototype.computePath = function() {
      var i, opts, points, result, v, values, x, y, _i, _len;
      values = this.$scope.data[0].values;
      opts = this.$scope.options;
      points = [];
      for (i = _i = 0, _len = values.length; _i < _len; i = ++_i) {
        v = values[i];
        x = this.xScale(opts.getX(v, i));
        y = this.yScale(opts.getY(v, i));
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
        data: '=rhData',
        options: '=rhOptions'
      },
      template: "<svg>\n	<g style='stroke: red;fill: none;'>\n		<path ng-attr-d={{ctrl.pathData}} />\n	</g>\n</svg>",
      link: function(scope, element, attrs, controller) {
        var domElem;
        domElem = element[0];
        scope.parentWidth = domElem.offsetWidth;
        return scope.parentHeight = domElem.offsetHeight;
      }
    };
  });

}).call(this);

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
            _this.computeArea();
            _this.computeScales();
            _this.computeLines();
            return _this.computeAxes();
          };
        })(this));
      }
    }

    LineChartCtrl.prototype.computeArea = function() {
      this.realWidth = this.$scope.parentWidth;
      return this.realHeight = this.$scope.parentHeight;
    };

    LineChartCtrl.prototype.computeScales = function() {
      var opts, values, xExtent, yExtent;
      values = this.$scope.data[0].values;
      opts = this.$scope.options;
      this.xScale = d3.scale.linear();
      this.yScale = d3.scale.linear();
      xExtent = d3.extent(values.map(opts.getX));
      this.xScale.domain(xExtent).range([0, this.realWidth]);
      yExtent = d3.extent(values.map(opts.getY));
      return this.yScale.domain(yExtent).range([this.realHeight, 0]);
    };

    LineChartCtrl.prototype.computePath = function(values) {
      var i, opts, points, result, v, x, y, _i, _len;
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

    LineChartCtrl.prototype.computeLines = function() {
      return this.pathData = this.computePath(this.$scope.data[0].values);
    };

    LineChartCtrl.prototype.computeAxes = function() {
      var yPosition;
      yPosition = this.yScale(0);
      return this.axis = {
        xPathData: "M0," + yPosition + "H" + this.realWidth,
        yPathData: "M0,0V" + this.realHeight
      };
    };

    return LineChartCtrl;

  })();

  module.controller(LineChartCtrl.name, LineChartCtrl);

  module.directive('rhLineChart', function($window) {
    return {
      restrict: 'EA',
      controller: LineChartCtrl.name,
      controllerAs: 'ctrl',
      scope: {
        data: '=rhData',
        options: '=rhOptions'
      },
      template: "<svg>\n	<g style='stroke: red;fill: none;' class='rh-lines'>\n		<path ng-attr-d={{ctrl.pathData}} />\n	</g>\n\n	<g style='stroke: black; stroke-width: 2px;' class='rh-axes'>\n		<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />\n		<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />\n		\n		<g class='ticks'>\n		</g>\n	</g>\n</svg>",
      link: function(scope, element, attrs, controller) {
        var calcSize;
        calcSize = function() {
          var domElem;
          domElem = element[0];
          scope.parentWidth = domElem.offsetWidth;
          return scope.parentHeight = domElem.offsetHeight;
        };
        calcSize();
        return $window.onresize = function() {
          return scope.$apply(function() {
            return calcSize();
          });
        };
      }
    };
  });

}).call(this);

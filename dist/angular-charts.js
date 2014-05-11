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
            return _this.chartUpdate();
          };
        })(this));
      }
    }

    LineChartCtrl.prototype.chartUpdate = function() {
      if (!this.sanityCheck()) {
        return;
      }
      this.computeArea();
      this.computeScales();
      this.computeLines();
      return this.computeAxes();
    };

    LineChartCtrl.prototype.sanityCheck = function() {
      if (this.$scope.data == null) {
        return false;
      }
      if (!angular.isArray(this.$scope.data)) {
        return false;
      }
      if (this.$scope.data.length === 0) {
        return false;
      }
      return true;
    };

    LineChartCtrl.prototype.computeArea = function() {
      var bottom, left;
      left = this.$scope.options.margin.left;
      bottom = this.$scope.options.margin.bottom;
      this.realWidth = this.$scope.parentWidth - left;
      this.realHeight = this.$scope.parentHeight - bottom;
      return this.marginTranslate = "translate(" + left + ",0)";
    };

    LineChartCtrl.prototype.computeScales = function() {
      var opts, values, xExtent, yExtent, yValues;
      values = this.$scope.data[0].values;
      opts = this.$scope.options;
      this.xScale = d3.scale.linear();
      this.yScale = d3.scale.linear();
      xExtent = d3.extent(values.map(opts.getX));
      this.xScale.domain(xExtent).range([0, this.realWidth]);

      /*
      		Figure out the maximum and minimum y-axis value
      		from all data points
       */
      yValues = d3.merge(this.$scope.data.map(function(d) {
        return d.values.map(opts.getY);
      }));
      yExtent = d3.extent(yValues);
      return this.yScale.domain(yExtent).range([this.realHeight, 0]);
    };

    LineChartCtrl.prototype.computePath = function(values) {

      /*
      		Given array of x,y pairs, Create <path> d= parameter. Like M0,100L100,0
      
      		For each point, need to compute the exact pixel coordinate location in <svg>
      		box.  That's why we use the xScale and yScale functions.
       */
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

      /*
      		Loop through all series' and create a <path> definition
      		for each line.
       */
      return this.lines = this.$scope.data.map((function(_this) {
        return function(d) {
          return _this.computePath(d.values);
        };
      })(this));
    };

    LineChartCtrl.prototype.computeAxes = function() {

      /*
      		Compute x,y locations for the tick grid lines
       */
      var xTicks, yPosition, yTicks;
      yPosition = this.yScale(0);
      yTicks = this.xScale.ticks().map((function(_this) {
        return function(t) {
          var xPos;
          xPos = _this.xScale(t);
          return "M" + xPos + ",0V" + _this.realHeight;
        };
      })(this));
      xTicks = this.yScale.ticks().map((function(_this) {
        return function(t) {
          var yPos;
          yPos = _this.yScale(t);
          return "M0," + yPos + "H" + _this.realWidth;
        };
      })(this));
      return this.axis = {
        xPathData: "M0," + yPosition + "H" + this.realWidth,
        yPathData: "M0,0V" + this.realHeight,
        yTicks: yTicks,
        xTicks: xTicks
      };
    };

    LineChartCtrl.prototype.strokeColor = function(i) {
      return d3.scale.category10().range()[i % 10];
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
      template: "<svg>\n	<g class='whole-chart' ng-attr-transform={{ctrl.marginTranslate}}>\n	    <g style='stroke: black; stroke-width: 2px;' class='rh-axes'>\n			<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />\n			<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />\n			\n			<g class='ticks' style='stroke: #ccc; stroke-width: 1px;'>\n				<path class='y-tick' \n					ng-repeat='tick in ctrl.axis.yTicks track by $index' \n					ng-attr-d={{tick}} />\n\n				<path class='x-tick' \n					ng-repeat='tick in ctrl.axis.xTicks track by $index' \n					ng-attr-d={{tick}} />\n			</g>\n		</g>\n		<g style='fill: none; stroke-width:1.5px' class='rh-lines'>\n			<path ng-repeat='line in ctrl.lines track by $index' \n				ng-attr-d={{line}} \n				ng-attr-stroke={{ctrl.strokeColor($index)}} />\n		</g>\n	</g>\n</svg>",
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

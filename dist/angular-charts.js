(function() {
  var LineChartCtrl, module;

  module = angular.module('rh.angular-charts', []);

  LineChartCtrl = (function() {
    function LineChartCtrl($scope, interactiveBisect) {
      var attr, _i, _len, _ref;
      this.$scope = $scope;
      this.interactiveBisect = interactiveBisect;
      this.pathData = '';
      this._displayGuideline = false;
      this.guidelinePath = 'M0,0';
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
      left = this.$scope.options.margin.left || 0;
      bottom = this.$scope.options.margin.bottom || 0;
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
      var xTickLabels, xTicks, yPosition, yTickLabels, yTicks;
      yPosition = this.yScale(0);
      xTickLabels = this.xScale.ticks().map((function(_this) {
        return function(t) {
          var config;
          return config = {
            label: t,
            x: _this.xScale(t)
          };
        };
      })(this));
      xTicks = this.xScale.ticks().map((function(_this) {
        return function(t) {
          var xPos;
          xPos = _this.xScale(t);
          return "M" + xPos + ",0V" + _this.realHeight;
        };
      })(this));
      yTickLabels = this.yScale.ticks().map((function(_this) {
        return function(t) {
          var config;
          return config = {
            label: t,
            y: _this.yScale(t)
          };
        };
      })(this));
      yTicks = this.yScale.ticks().map((function(_this) {
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
        xTicks: xTicks,
        yTickLabels: yTickLabels,
        xTickLabels: xTickLabels
      };
    };

    LineChartCtrl.prototype.updateGuideline = function(evt) {
      var result, xDomain, xPixel, xPos;
      xPixel = evt.offsetX - this.$scope.options.margin.left;
      xDomain = this.xScale.invert(xPixel);
      result = this.interactiveBisect(this.$scope.data[0].values, xDomain, this.$scope.options.getX);
      xPos = this.xScale(result);
      return this.guidelinePath = "M" + xPos + ",0V" + this.realHeight;
    };

    LineChartCtrl.prototype.showGuideline = function(flag) {
      if (flag == null) {
        return this._displayGuideline;
      }
      return this._displayGuideline = flag;
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
      template: "<svg>\n	<g class='whole-chart rh-chart' ng-attr-transform={{ctrl.marginTranslate}}>\n	    <g style='stroke: black;' class='rh-axes'>\n			<path class='x-axis' ng-attr-d={{ctrl.axis.xPathData}} />\n			<path class='y-axis' ng-attr-d={{ctrl.axis.yPathData}} />\n			\n			<g class='ticks' style='stroke: #ccc; stroke-width: 1px;'>\n				<path class='y-tick' \n					ng-repeat='tick in ctrl.axis.yTicks track by $index' \n					ng-attr-d={{tick}} />\n\n				<path class='x-tick' \n					ng-repeat='tick in ctrl.axis.xTicks track by $index' \n					ng-attr-d={{tick}} />\n			</g>\n\n			<g class='labels'>\n				<text\n					ng-repeat='label in ctrl.axis.yTickLabels' \n					ng-attr-y={{label.y}}\n					x='-10'\n					class='y-tick'\n					stroke='none' \n					text-anchor='end'>\n\n				{{label.label}}\n				</text>\n\n				<text\n					ng-repeat='label in ctrl.axis.xTickLabels' \n					ng-attr-x={{label.x}}\n					ng-attr-y={{ctrl.realHeight+10}}\n					class='x-tick' \n					stroke='none'\n					text-anchor='middle'>\n\n				{{label.label}}\n				</text>\n			</g>\n		</g>\n		<g style='fill: none; stroke-width:1.5px' class='rh-lines'>\n			<path ng-repeat='line in ctrl.lines track by $index' \n				ng-attr-d={{line}} \n				ng-attr-stroke={{ctrl.strokeColor($index)}} />\n		</g>\n\n		<path class='guideline' \n			stroke='#aaa'\n			ng-attr-d={{ctrl.guidelinePath}} \n			ng-if='ctrl.showGuideline()' />\n\n		<rect \n			class='interactive-layer' \n			ng-mouseenter='ctrl.showGuideline(true)'\n			ng-mouseleave='ctrl.showGuideline(false)'\n			ng-mousemove='ctrl.updateGuideline($event)'\n			ng-attr-height={{ctrl.realHeight}}\n			ng-attr-width={{ctrl.realWidth}} />\n	</g>\n</svg>",
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

(function() {
  var module;

  module = angular.module('rh.angular-charts');


  /*
  Utility class that uses d3.bisect to find the index in a given array, where a search value can be inserted.
  This is different from normal bisectLeft; this function finds the nearest index to insert the search value.
  
  For instance, lets say your array is [1,2,3,5,10,30], and you search for 28. 
  Normal d3.bisectLeft will return 4, because 28 is inserted after the number 10.  But interactiveBisect will return 5
  because 28 is closer to 30 than 10.
  
  Unit tests can be found in: interactiveBisectTest.html
  
  Has the following known issues:
     * Will not work if the data points move backwards (ie, 10,9,8,7, etc) or if the data points are in random order.
     * Won't work if there are duplicate x coordinate values.
   */

  module.factory('interactiveBisect', function() {
    var interactiveBisect;
    return interactiveBisect = function(values, search, getX) {
      var bisect, index, nextVal, prevIndex, prevVal;
      if (!angular.isArray(values)) {
        return null;
      }
      if (values.length === 0) {
        return null;
      }
      if (values.length === 1) {
        return 0;
      }
      bisect = function(vals, sch) {
        var d, i, val, _i, _len;
        for (i = _i = 0, _len = vals.length; _i < _len; i = ++_i) {
          d = vals[i];
          val = getX(d, i);
          if (val >= sch) {
            return i;
          }
        }
        return vals.length;
      };
      index = bisect(values, search);
      index = d3.min([index, values.length - 1]);
      if (index > 0) {
        prevIndex = index - 1;
        prevVal = getX(values[prevIndex], prevIndex);
        nextVal = getX(values[index], index);
        if (Math.abs(search - prevVal) < Math.abs(search - nextVal)) {
          index = prevIndex;
        }
      }
      return index;
    };
  });

}).call(this);

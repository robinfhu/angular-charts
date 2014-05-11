module = angular.module 'rh.angular-charts'
###
Utility class that uses d3.bisect to find the index in a given array, where a search value can be inserted.
This is different from normal bisectLeft; this function finds the nearest index to insert the search value.

For instance, lets say your array is [1,2,3,5,10,30], and you search for 28. 
Normal d3.bisectLeft will return 4, because 28 is inserted after the number 10.  But interactiveBisect will return 5
because 28 is closer to 30 than 10.

Unit tests can be found in: interactiveBisectTest.html

Has the following known issues:
   * Will not work if the data points move backwards (ie, 10,9,8,7, etc) or if the data points are in random order.
   * Won't work if there are duplicate x coordinate values.
###
module.factory 'interactiveBisect', ->
	interactiveBisect = (values,search,getX)->
		return null unless angular.isArray values 
		return null if values.length is 0
		return 0 if values.length is 1

		bisect = d3.bisector(getX).left

		index = bisect values,search

		index = d3.min [index, values.length-1]
		if index > 0
			prevIndex = index-1
			prevVal = getX(values[prevIndex])
			nextVal = getX(values[index])

			if Math.abs(search-prevVal) < Math.abs(search-nextVal)
				index = prevIndex			

		index


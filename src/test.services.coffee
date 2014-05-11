describe 'services', ->
	beforeEach angular.mock.module 'rh.angular-charts'

	describe 'interactive bisect function', ->
		bisect = null
		beforeEach inject (interactiveBisect)->
			bisect = interactiveBisect

		it 'exists', ->
			should.exist bisect 

		createSample = (data=[])->
			data.map (d)->
				x: d 
				y: 12345

		getX = (d)-> d.x 

		it 'returns null for bad input', ->
			result = bisect []

			should.not.exist result 

			result = bisect null

			should.not.exist result 

		it 'can search on a single point', ->
			for search in [-10,3,5,9]
				result = bisect createSample([5]), search, getX 

				result.should.equal 0, "for searchVal: #{search}"


		it 'can search between three points', ->
			sample = createSample [5,6,7]

			result = bisect sample, 5, getX
			result.should.equal 0

			result = bisect sample, 6, getX
			result.should.equal 1

			result = bisect sample, 7, getX
			result.should.equal 2

			result = bisect sample, 100, getX
			result.should.equal 2, 'all the way past end'

			result = bisect sample, 4.7, getX
			result.should.equal 0, '4.7 value'

			result = bisect sample, 5.8, getX
			result.should.equal 1, '5.8 value'

			result = bisect sample, 6.9, getX
			result.should.equal 2, '6.9 value'

			result = bisect sample, 5.01, getX
			result.should.equal 0, '5.01 value'

		it 'can search between irregular points', ->
			sample = createSample [1,3,10,60,100]

			result = bisect sample, 10, getX
			result.should.equal 2

			result = bisect sample, 25.4, getX
			result.should.equal 2

			result = bisect sample, 80, getX
			result.should.equal 4

			result = bisect sample, 100.1, getX
			result.should.equal 4

			for i in [-10..150]
				result = bisect sample, i, getX
				result.should.be.within(0,4)



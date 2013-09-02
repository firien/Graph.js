# Bar Graph implementation

#     new Graph(svg).Bar(data);

class Bar
  constructor: (@data, @options, @svg) ->
    animation = true
    #ensure labels and datasets have same count
    for dataset in @data.datasets
      if dataset.data.length != @data.labels.length
        throw "up"
    #determine scale
    min = Math.min.apply(null, @data.datasets.map (array) ->
      Math.min.apply(null, array.data)
    )
    max = Math.max.apply(null, @data.datasets.map (array) ->
      Math.max.apply(null, array.data)
    )
    rangeOrderOfMagnitude = Math.floor(Math.log(max - min) / Math.LN10)
    stepValue = Math.pow(10, rangeOrderOfMagnitude)
    graphMin = Math.floor(min / (1 * stepValue)) * stepValue  
    graphMax = Math.ceil(max / (1 * stepValue)) * stepValue  
    numberOfSteps = Math.round((graphMax - graphMin) / stepValue)
    height = 375
    #y = mx + b
    fnY = (_y) -> (height / (graphMin - graphMax)) * (_y - graphMax)
    #draw scale
    y = graphMin
    while y <= graphMax
      text = document.createElementNS('http://www.w3.org/2000/svg', 'text')
      text.setAttribute 'x', 0
      text.setAttribute 'y', fnY(y)
      text.appendChild document.createTextNode(y)
      @svg.appendChild text
      y += stepValue
    #draw bars
    fnX = ((setCount) ->
      (_i, _j) ->
        (_j + 1) * (35 * setCount) + (30 * i)
    )(@data.datasets.length)
    for dataset, i in @data.datasets
      for datum, j in dataset.data
        rect = Graph.createSVGElement('rect', {
          x: fnX(i, j)
          y: if animation then height else fnY(datum)
          height: if animation then 0 else height - fnY(datum)
          width: 30
          fill: dataset.fillColor
        })
        if dataset.strokeColor?
          rect.setAttribute 'stroke', dataset.strokeColor
          rect.setAttribute 'stroke-width', 1
        @svg.appendChild rect
        #animate
        if animation
          #animate y attribute
          animate = Graph.createSVGElement('animate', {
            attributeName: "y"
            attributeType: "XML"
            dur: "0.4s"
            fill: "freeze"
            values: "#{height}; #{fnY(datum)}"
            keyTimes: "0; 1"
            keySplines: ".5 0 .5 1"
            calcMode: "spline"
          })
          rect.appendChild animate
          #animate height attribute
          animate = Graph.createSVGElement('animate', {
            attributeName: "height"
            attributeType: "XML"
            dur: "0.4s"
            fill: "freeze"
            values: "0; #{height - fnY(datum)}"
            keyTimes: "0; 1"
            keySplines: ".5 0 .5 1"
            calcMode: "spline"
          })
          rect.appendChild animate
        # sneaky closure trick for events
        if dataset.fnMouseOver
          do (dataset, datum) ->
            rect.addEventListener('mouseover', (e) ->
              dataset.fnMouseOver e, datum
            )
    # reset 'clock' to trigger animations
    @svg.setCurrentTime 0
    
  # Default Bar Graph options
  @defaults = {
  	# Boolean - If we show the scale above the chart data
  	scaleOverlay : false
  	# Boolean - If we want to override with a hard coded scale
  	scaleOverride : false
  	# **Required if scaleOverride is true**
    #
  	# Number - The number of steps in a hard coded scale
  	scaleSteps : null
  	#   Number - The value jump in the hard coded scale
  	scaleStepWidth : null
  	# Number - The scale starting value
  	scaleStartValue : null
  	# String - Colour of the scale line
  	scaleLineColor : "rgba(0,0,0,.1)"
  	# Number - Pixel width of the scale line
  	scaleLineWidth : 1
  	# Boolean - Whether to show labels on the scale
  	scaleShowLabels : true
  	# Interpolated JS string - can access value
  	scaleLabel : "<%=value%>"
  	# String - Scale label font declaration for the scale label
  	scaleFontFamily : "'Arial'"
  	# Number - Scale label font size in pixels
  	scaleFontSize : 12
  	# String - Scale label font weight style
  	scaleFontStyle : "normal"
  	# String - Scale label font colour
  	scaleFontColor : "#666"
  	# Boolean - Whether grid lines are shown across the chart
  	scaleShowGridLines : true
  	# String - Colour of the grid lines
  	scaleGridLineColor : "rgba(0,0,0,.05)"
  	# Number - Width of the grid lines
  	scaleGridLineWidth : 1
  	# Boolean - If there is a stroke on each bar
  	barShowStroke : true
  	# Number - Pixel width of the bar stroke
  	barStrokeWidth : 2
  	# Number - Spacing between each of the X value sets
  	barValueSpacing : 5
  	# Number - Spacing between data sets within X values
  	barDatasetSpacing : 1
  	# Boolean - Whether to animate the chart
  	animation : true
  	# Number - Number of animation steps
  	animationSteps : 60
  	# String - Animation easing effect
  	animationEasing : "easeOutQuart"
  	# Function - Fires when the animation is complete
  	onAnimationComplete : null
  }
  #extend `Graph`
Graph::Bar = (data, options) ->
  new Bar(data, options, @svgElement)

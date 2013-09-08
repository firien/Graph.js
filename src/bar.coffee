# Bar Graph implementation

#     new Graph(svg).Bar(data);

class Bar
  constructor: (@data, @options, @svg) ->
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
    g = Graph.createSVGElement('g')
    while y <= graphMax
      text = Graph.createSVGElement('text', {
        x: 25
        y: fnY(y)
      })
      text.appendChild document.createTextNode(y)
      g.appendChild text
      y += stepValue
    @svg.appendChild g
    #draw bars
    fnX = ((setCount) ->
      (_i, _j) ->
        gutter = 30
        (_j * 30 * setCount) + (25 * _i) + gutter
    )(@data.datasets.length)
    for dataset, i in @data.datasets
      for datum, j in dataset.data
        rect = Graph.createSVGElement('rect', {
          x: fnX(i, j)
          y: if @options.animation then height else fnY(datum)
          height: if @options.animation then 0 else height - fnY(datum)
          width: 25
          fill: dataset.fillColor
        })
        if dataset.strokeColor?
          rect.setAttribute 'stroke', dataset.strokeColor
          rect.setAttribute 'stroke-width', 1
        @svg.appendChild rect
        #animate
        if @options.animation
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
    @svg.setCurrentTime 0 if @options.animation
    
  # Default Bar Graph options
  @defaults = {
    animation: true
  }
  #extend `Graph`
Graph::Bar = (data, options={}) ->
  for key, value of Bar.defaults
    unless options.hasOwnProperty key
      options[key] = value
  new Bar(data, options, @svgElement)

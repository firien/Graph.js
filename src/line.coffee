# Line Graph implementation

#     new Graph(svg).Line(data);

class Line
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
    fnX = (_j) ->
      gutter = 30
      (_j * 90) + gutter
    for dataset, i in @data.datasets
      d = "M 30 #{height} "
      dStart = "M 30 #{height} "
      path = Graph.createSVGElement('path', {
        fill: dataset.fillColor
      })
      d += "V #{fnY(dataset.data[0])} "
      dStart += "V #{height} "
      dataset.data.reduce (previousValue, currentValue, index) ->
        x1 = fnX(index - 1)
        y1 = fnY(previousValue)
        x2 = fnX(index)
        y2 = fnY(currentValue)
        x3 = x1 + ((x2 - x1) / 2)
        d += "C #{x3} #{y1} #{x3} #{y2} #{x2} #{y2} "
        dStart += "C #{x3} #{height} #{x3} #{height} #{x2} #{height} "
        return currentValue
      d += "V #{height} z"
      dStart += "V #{height} z"
      path.setAttribute 'd', if animation then dStart else d
      if animation
        #animate d attribute
        animate = Graph.createSVGElement('animate', {
          attributeName: "d"
          attributeType: "XML"
          dur: "0.4s"
          fill: "freeze"
          from: dStart
          to: d
          keyTimes: "0; 1"
          keySplines: ".5 0 .5 1"
          calcMode: "spline"
        })
        path.appendChild animate
      @svg.appendChild path
    # reset 'clock' to trigger animations
    @svg.setCurrentTime 0
    
  #extend `Graph`
Graph::Line = (data, options) ->
  new Line(data, options, @svgElement)

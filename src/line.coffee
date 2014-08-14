# Line Graph implementation

#     new Graph(svg).Line(data);

class Line
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
    rect = g.getBBox()
    gutter = rect.x + rect.width
    fnX = (_j) ->
      (_j * 70) + gutter
    # x-axis labels??
    for label, i in @data.labels
      text = Graph.createSVGElement('text', {
        'text-anchor': 'middle'
        x: fnX(i)
        y: height + 20
      })
      text.appendChild document.createTextNode(label)
      @svg.appendChild text
    #plot data
    for dataset, i in @data.datasets
      d = "M #{gutter} #{height} "
      dStart = "M #{gutter} #{height} "
      path = Graph.createSVGElement('path', {
        # fillColor should have opacity, or it will obscure other paths
        # unless there is only one dataset
        fill: dataset.fillColor
      })
      d += "V #{fnY(dataset.data[0])} "
      dStart += "V #{height} "
      if @options.bezierCurve
        dataset.data.reduce (previousValue, currentValue, index) ->
          # cubic bezier curve from x1, y1 to x2, y2
          x1 = fnX(index - 1)
          y1 = fnY(previousValue)
          x2 = fnX(index)
          y2 = fnY(currentValue)
          # both control points have same X value
          #  halfway between x1 and x2
          cpX = x1 + ((x2 - x1) / 2)
          d += "C #{cpX} #{y1} #{cpX} #{y2} #{x2} #{y2} "
          dStart += "C #{cpX} #{height} #{cpX} #{height} #{x2} #{height} "
          return currentValue
      else#line
        dataset.data.reduce (previousValue, currentValue, index) ->
          x2 = fnX(index)
          y2 = fnY(currentValue)
          d += "L #{x2} #{y2} "
          dStart += "L #{x2} #{height} "
          return currentValue
      d += "V #{height} z"
      dStart += "V #{height} z"
      path.setAttribute 'd', if @options.animation then dStart else d
      if @options.animation
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
      if dataset.fnMouseOver
        do (dataset) ->
          path.addEventListener('mouseover', (e) ->
            dataset.fnMouseOver e, dataset.data
          )
          return
    # reset 'clock' to trigger animations
    @svg.setCurrentTime 0 if @options.animation
    #legend?
    g = Graph.createSVGElement('g', {class: 'legend'})
    size = 20
    step = Math.floor((height - (@data.datasets.length * size)) / (@data.datasets.length - 1))
    for datum, j in @data.datasets
      rect = Graph.createSVGElement('rect', {
        x: height + 0.5 + 10
        y: j * (size + step) + 0.5
        width: size
        height: size
        fill: datum.fillColor
      })
      g.appendChild rect
      text = Graph.createSVGElement('text', {
        x: height + 0.5 + 40
        y: j * (size + step) + 0.5 + 10
      })
      text.appendChild document.createTextNode(datum.label)
      g.appendChild text
    @svg.appendChild g
  # Default Line Graph options
  @defaults = {
    animation: true
    bezierCurve: true
  }
  #extend `Graph`
Graph::Line = (data, options={}) ->
  for key, value of Line.defaults
    unless options.hasOwnProperty key
      options[key] = value
  new Line(data, options, @svgElement)

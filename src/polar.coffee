# Polar Graph implementation

#     new Graph(svg).Polar(data);

class Polar
  constructor: (@data, @options, @svg) ->
    #determine scale
    min = Math.min.apply(null, @data.map (element) ->
      element.value
    )
    max = Math.max.apply(null, @data.map (element) ->
      element.value
    )
    rangeOrderOfMagnitude = Math.floor(Math.log(max - min) / Math.LN10)
    stepValue = Math.pow(10, rangeOrderOfMagnitude)
    graphMin = Math.floor(min / (1 * stepValue)) * stepValue
    graphMax = Math.ceil(max / (1 * stepValue)) * stepValue
    numberOfSteps = Math.round((graphMax - graphMin) / stepValue)
    height = 375
    fnY = (x) ->
      #y = mx + b
      #y = (y1-y2) / (x1-x2) * (x - x1) + y1
      ((height / 2 - 0) / (graphMin - graphMax)) * (x - graphMin) + (height / 2)
    #draw scale
    y = graphMin
    g = Graph.createSVGElement('g')
    while y <= graphMax
      circle = Graph.createSVGElement('circle', {
        cx: height / 2
        cy: height / 2
        r:  fnY(y)
      })
      # text.appendChild document.createTextNode(y)
      g.appendChild circle
      y += stepValue
    @svg.appendChild g
    #draw sectors
    #
    #find x, y of any point on circle with center at 
    fnXY = (r,_theta) -> {
      x: r * Math.cos(_theta - Math.PI / 2) + height / 2
      y: r * Math.sin(_theta - Math.PI / 2) + height / 2
    }
    theta = 0
    for datum, j in @data
      d = "M #{height / 2} #{height / 2} "
      _r = height / 2 - fnY(datum.value)
      p1 = fnXY(_r, theta)
      dStart = "M #{height / 2} #{height / 2} "
      path = Graph.createSVGElement('path', {
        # fillColor should have opacity, or it will obscure other paths
        # unless there is only one dataset
        fill: datum.fillColor
        stroke: '#ddd'
        'fill-opacity': 0.8
      })
      d += "L #{p1.x} #{p1.y} "
      dStart += "?? "
      theta += (2 * Math.PI / @data.length)
      p2 = fnXY(_r, theta)
      d += "A #{_r} #{_r} 0 0 1 #{p2.x} #{p2.y} z"
      dStart += "V #{height} "
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
    # reset 'clock' to trigger animations
    @svg.setCurrentTime 0 if @options.animation

  # Default Polar Graph options
  @defaults = {
    animation: false
    scaleOverride: false
    scaleSteps: null
    scaleStepWidth: null
    scaleStartValue: null
  }
  #extend `Graph`
Graph::Polar = (data, options={}) ->
  for key, value of Polar.defaults
    unless options.hasOwnProperty key
      options[key] = value
  new Polar(data, options, @svgElement)

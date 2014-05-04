# Polar Graph implementation

#     new Graph(svg).Polar(data);

class Polar
  constructor: (@data, @options, @svg) ->
    group = Graph.createSVGElement('g', {
      class: 'polar',
      transform: 'translate(5,10)'
    })
    height = @options.scaleSize
    #determine scale
    if @options.scaleOverride
      stepValue = @options.scaleStepWidth
      graphMin = @options.scaleStartValue
      graphMax = stepValue * @options.scaleSteps
    else
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
    fnY = (x) ->
      #y = mx + b
      #y = (y1-y2) / (x1-x2) * (x-x1) + y1
      ((height / 2 - 0) / (graphMin - graphMax)) * (x - graphMin) + (height / 2)
    #draw scale
    y = graphMin
    g = Graph.createSVGElement('g')
    while y <= graphMax
      _r = height / 2 - fnY(y)
      if _r > 0
        circle = Graph.createSVGElement('circle', {
          cx: height / 2
          cy: height / 2
          r:  _r
          data: y
        })
        g.appendChild circle
      y += stepValue
    group.appendChild g
    #draw sectors
    #
    #find x, y of any point on circle with center at
    fnXY = (r,_theta) -> {
      x: r * Math.cos(_theta - Math.PI / 2) + height / 2
      y: r * Math.sin(_theta - Math.PI / 2) + height / 2
    }
    theta = 0
    g = Graph.createSVGElement('g')
    for datum, j in @data
      cx = height / 2
      d = "M #{cx} #{cx} "
      _r = height / 2 - fnY(datum.value)
      p1 = fnXY(_r, theta)
      dStart = "M #{cx} #{cx} "
      path = Graph.createSVGElement('path', {
        # fillColor should have opacity, or it will obscure other paths
        # unless there is only one dataset
        fill: datum.fillColor
        stroke: '#ddd'
        'fill-opacity': 0.8
      })
      d += "L #{p1.x} #{p1.y} "
      dStart += "L #{cx} #{cx} "
      theta += (2 * Math.PI / @data.length)
      p2 = fnXY(_r, theta)
      d += "A #{_r} #{_r} 0 0 1 #{p2.x} #{p2.y} z"
      dStart += "A 1 1 0 0 1 #{cx} #{cx} z"
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
      g.appendChild path
    group.appendChild g
    # reset 'clock' to trigger animations
    @svg.setCurrentTime 0 if @options.animation
    #draw scale
    y = graphMin
    g = Graph.createSVGElement('g', {class: 'scale'})
    while y <= graphMax
      _r = fnY(y)
      if y > 0
        text = Graph.createSVGElement('text', {
          x: height / 2
          y: _r
        })
        text.appendChild document.createTextNode(y)
        g.appendChild text
      y += stepValue
    group.appendChild g
    #legend
    g = Graph.createSVGElement('g', {class: 'legend'})
    size = 20
    step = Math.floor((height - (@data.length * size)) / (@data.length - 1))
    for datum, j in @data
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
    group.appendChild g
    @svg.appendChild group

  @injectStyles = ->
    style = document.querySelector('style[title=polar]')
    unless style?
      style = document.createElement "style"
      style.setAttribute('title', 'polar')
      # WebKit hack :(
      # style.appendChild(document.createTextNode(""))
      document.head.appendChild style
      #add rules
      Graph.addRule(style.sheet, "g.polar circle", {
        fill: 'none'
        stroke: "#ccc"
      })
      Graph.addRule(style.sheet, "g.polar g.scale text", {
        'alignment-baseline': 'middle'
        'text-anchor': 'middle'
        'pointer-events': 'none'
        'font-family': 'Helvetica'
        'font-size': '0.8em'
        fill: "#666"
      })
      Graph.addRule(style.sheet, "g.polar g.legend rect", {
        stroke: "#222"
      })
      Graph.addRule(style.sheet, "g.polar g.legend text", {
        'alignment-baseline': 'middle'
        'font-family': 'Helvetica'
      })

  # Default Polar Graph options
  @defaults = {
    animation: false
    scaleOverride: false
    scaleSteps: null
    scaleStepWidth: null
    scaleStartValue: null
    scaleSize: 350
  }
  #extend `Graph`
Graph::Polar = (data, options={}) ->
  for key, value of Polar.defaults
    unless options.hasOwnProperty key
      options[key] = value
  new Polar(data, options, @svgElement)
  Polar.injectStyles()

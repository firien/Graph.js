class Graph
  constructor: (@svgElement) ->
    #original intent was to clone `svgElement`, but WebKit has a problem with animations and injected `<svg>` nodes.
    # http://code.google.com/p/chromium/issues/detail?id=122846
    @svgElement.removeChild @svgElement.firstChild while @svgElement.firstChild?
    @svgElement.setAttribute 'width', '700'
    @svgElement.setAttribute 'height', '500'
  #
  # Create a properly namespaced SVG element
  #
  # Example:
  #
  #     var rect = Graph.createSVGElement('rect', {
  #        x: 4,
  #        y: 4,
  #        height: 20,
  #        width: 30
  #     })
  #     // => <rect x="4" y="4" height="20" width="30"/>
  @createSVGElement: (nodeName, attributes) ->
    node = document.createElementNS('http://www.w3.org/2000/svg', nodeName)
    if attributes?
      for attr, val of attributes
        node.setAttribute attr, val
    return node

#expose as `Graph`
window.Graph = Graph

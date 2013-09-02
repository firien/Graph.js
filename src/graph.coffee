class Graph
  constructor: (@svgElement) ->
    # clone = @svgElement.cloneNode()
    # clone = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    #apply graph class to svgElement
    # clone.setAttribute 'class', 'graph'
    @svgElement.setAttribute 'width', '700'
    @svgElement.setAttribute 'height', '500'
    #replace `svgElement` with new virgin clone
    # @svgElement.parentNode.replaceChild clone, @svgElement
    # @svgElement = clone
  #
  # create a properly namespaced SVG element
  #
  # Example:
  #
  #     var rect = Graph.createSVGElement('rect', {x: 4, y: 4, height: 20, width: 30})
  @createSVGElement: (nodeName, attributes) ->
    node = document.createElementNS('http://www.w3.org/2000/svg', nodeName)
    if attributes?
      for attr, val of attributes
        node.setAttribute attr, val
    return node

#expose as `Graph`
window.Graph = Graph

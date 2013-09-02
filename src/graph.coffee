class Graph
  constructor: (@svgElement) ->
    # clone = @svgElement.cloneNode()
    # clone = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    #apply graph class to svgElement
    # clone.setAttribute 'class', 'graph'
    @svgElement.setAttribute 'width', '600'
    @svgElement.setAttribute 'height', '500'
    #replace `svgElement` with new virgin clone
    # @svgElement.parentNode.replaceChild clone, @svgElement
    # @svgElement = clone

#expose as `Graph`
window.Graph = Graph

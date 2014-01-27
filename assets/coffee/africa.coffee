# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author :
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 16-Jan-2014
# Last mod : 27-Jan-2014
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
#
#    NAVIGATION
#
# -----------------------------------------------------------------------------
class Navigation
  CONFIG=
    urls :
        geojson : "static/data/continent_Africa_subunits.json"
        tour    : "static/data/tour.json"

  constructor: ->
    @projects        = undefined
    @current_project = undefined

  start: =>
    queue()
      .defer(d3.json, CONFIG.urls.geojson)
      .defer(d3.json, CONFIG.urls.tour)
      .await(@loadedDataCallback)

  loadedDataCallback: (error, geojson, tour) =>
    @geojson  = geojson
    @projects = tour
    @map      = new Africa(@)
    @panel    = new Panel(@)

  setProject: (project) =>
    @panel.setProject(project)

  nextProject: =>

  previousProject: =>

# -----------------------------------------------------------------------------
#
#    PANEL
#
# -----------------------------------------------------------------------------
class Panel

  constructor: ->
    @UIS =
      title       : $(".Panel .title")
      location    : $(".Panel .location")
      description : $(".Panel .single_project .description")

  setProject: (project) =>
    @UIS.title.html(project.title)
    @UIS.location.html(project.recipient_condensed)
    @UIS.description.html(project.description)

# -----------------------------------------------------------------------------
#
#    AFRICA
#
# -----------------------------------------------------------------------------
class Africa
  # Define default config
  CONFIG =
    svg_block_selector : ".africa-container"
    svg_height         : 500
    svg_width          : 500
    scale_range        : [6, 9]
  #
  # Contruct class instance
  #
  constructor: (navigation) ->
    @navigation = navigation
    @countries  = navigation.geojson.features
    @projects   = navigation.projects

    # Create svg tag
    @svg = d3.select(CONFIG.svg_block_selector)
      .insert("svg", ":first-child")
      .attr("width", CONFIG.svg_width)
      .attr("height", CONFIG.svg_height)

    # Create projection
    @projection = d3.geo.mercator()
      .center([0, 5])
      .scale(350)
      .rotate([-55,5])

    # Create the Africa path
    @path = d3.geo.path()
      .projection(@projection)

    # Create the group of path and add graticule
    @groupPaths = @svg.append("g")
      .attr("class", "all-path")

    @groupPoints = @svg.append("g")
      .attr("class", "all-points")

    @drawMap()

  drawMap: =>
    that = this
    # compute scale
    values = @projects.map((d) -> parseFloat(d.usd_defl))
    scale  = d3.scale.linear()
      .domain([Math.min.apply(Math, values), Math.max.apply(Math, values)])
      .range(CONFIG.scale_range)
    # Create every countries
    @groupPaths.selectAll("path")
      .data(@countries)
      .enter()
        .append("path")
        .attr("d", @path)
    @groupPoints.selectAll("circle")
      .data(@projects)
      .enter()
        .append("circle")
          .attr("cx", (d) -> that.projection([d.lon, d.lat])[0])
          .attr("cy", (d) -> that.projection([d.lon, d.lat])[1])
          .attr("r",  (d) -> scale(parseFloat(d.usd_defl)))
          .on('click', @setProject)

  setProject: (project) =>
    @navigation.setProject(project)

# -----------------------------------------------------------------------------
#
#    MAIN
#
# -----------------------------------------------------------------------------
navigation = new Navigation()
navigation.start()

# EOF

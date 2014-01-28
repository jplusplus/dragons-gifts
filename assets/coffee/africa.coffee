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

  CONFIG =
    urls :
      geojson : "static/data/continent_Africa_subunits.json"
      tour    : "static/data/tour.json"

  constructor: ->
    @projects        = undefined
    @current_project = 0

    @UIS =
      prv_button : $("#prv_button")
      nxt_button : $("#nxt_button")

    @UIS.prv_button.on 'click', @previousProject
    @UIS.nxt_button.on 'click', @nextProject


  start: =>
    queue()
      .defer(d3.json, CONFIG.urls.geojson)
      .defer(d3.json, CONFIG.urls.tour)
      .await(@loadedDataCallback)

  loadedDataCallback: (error, geojson, tour) =>
    @geojson  = geojson
    @projects = tour
    @map      = new AfricaMap(this, @geojson.features, @projects)
    @panel    = new Panel(this)
    @setProject(@current_project)

  setProject: (project) =>
    if typeof(project) is "number"
      project = @projects[project]
    @current_project = @projects.indexOf(project)
    $(document).trigger("projectSelected", project)

  nextProject: =>
    if @current_project < @projects.length - 1
      @setProject(@projects[@current_project + 1])

  previousProject: =>
    if @current_project > 0
      @setProject(@projects[@current_project - 1])

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

    # Bind events
    $(document).on("projectSelected", @onProjectSelected)

  onProjectSelected: (e, project) =>
    @UIS.title       .html project.title
    @UIS.location    .html project.recipient_condensed
    @UIS.description .html project.description

# -----------------------------------------------------------------------------
#
#    AFRICA MAP
#
# -----------------------------------------------------------------------------
class AfricaMap
  # Define default config
  CONFIG =
    svg_block_selector : ".africa-container"
    svg_height         : 500
    svg_width          : 500
    scale_range        : [6, 9]
  #
  # Contruct class instance
  #
  constructor: (navigation, countries, projects) ->
    @navigation = navigation
    @countries  = countries
    @projects   = projects

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

    # Bind events
    $(document).on("projectSelected", @onProjectSelected)

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

    @circles = @groupPoints.selectAll("circle")
      .data(@projects)
      .enter()
        .append("circle")
          .attr("cx", (d) -> that.projection([d.lon, d.lat])[0])
          .attr("cy", (d) -> that.projection([d.lon, d.lat])[1])
          .attr("r" , (d) -> scale(parseFloat(d.usd_defl)))
          .on('click', @navigation.setProject)

  onProjectSelected: (e, project) =>
    @circles.each (d, i) ->
      d3.select(this).classed("active", project is d)

# -----------------------------------------------------------------------------
#
#    MAIN
#
# -----------------------------------------------------------------------------
navigation = new Navigation()
navigation.start()

# EOF

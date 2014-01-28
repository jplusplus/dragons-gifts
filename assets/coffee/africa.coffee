# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author :
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 16-Jan-2014
# Last mod : 28-Jan-2014
# -----------------------------------------------------------------------------

MODE_INTRO          = 0
MODE_TOUR           = 1
MODE_START_OVERVIEW = 2
MODE_OVERVIEW       = 3

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
    @mode            = undefined
    @current_project = undefined

    @uis =
      page : $(".container:first")

  start: =>
    queue()
      .defer(d3.json, CONFIG.urls.geojson)
      .defer(d3.json, CONFIG.urls.tour)
      .await(@loadedDataCallback)

  loadedDataCallback: (error, geojson, tour) =>
    @setMode(MODE_INTRO)
    @geojson  = geojson
    @projects = tour
    @map      = new AfricaMap(this, @geojson.features, @projects)
    @panel    = new Panel(this)

  setMode: (mode) =>
    if @mode != mode
      @mode = mode
      # set a project if the tour mode is selected
      if @mode == MODE_TOUR then @setProject(0) else @setProject(null)
      # trigger an event for the others widgets
      $(document).trigger("modeChanged", @mode)

  setProject: (project) =>
    """
    use this function to set a project.
    it will trigger an projectSelected event that all the other widget
    are able to bind.
    """
    # ensure the mode
    @setMode(MODE_TOUR) unless not project?
    # we need an interger as @current_project
    if project? and typeof(project) is "object"
      project = @projects.indexOf(project)
    # save the state of the selected project
    @current_project = project
    # trigger a projectSelected with the selected project or null if no project is selected
    $(document).trigger("projectSelected", if @current_project? then @projects[@current_project] else null)

  nextProject: =>
    if @hasNext()
      @setProject(@projects[@current_project + 1])
    else # if it's after the last project, we switch to the START_OVERVIEW mode
      @setMode(MODE_START_OVERVIEW)

  previousProject: =>
    if @hasPrevious()
      @setProject(@projects[@current_project - 1])
    else # if it's before the first project, we switch to the INTRO mode
      @setMode(MODE_INTRO)

  hasNext    : => @current_project < @projects.length - 1
  hasPrevious: => @current_project > 0

# -----------------------------------------------------------------------------
#
#    PANEL
#
# -----------------------------------------------------------------------------
class Panel

  constructor: (navigation) ->

    @navigation = navigation

    @uis =
      views          : $(".Panel .view")
      intro          : $(".Panel .view.intro_main")
      single_project : $(".Panel .view.single_project")
      start_overview : $(".Panel .view.start_overview")
      overview       : $(".Panel .view.overview")
      navigation_btn : $(".Panel .navigation-buttons")
      prv_button     : $(".Panel .prv_button")
      nxt_button     : $(".Panel .nxt_button")
      tour_button    : $(".Panel .tour_button")
      overview_button: $(".Panel .overview_button")
      title          : $(".Panel .single_project .title")
      location       : $(".Panel .single_project .location")
      description    : $(".Panel .single_project .description")

    # Bind events
    $(window).resize(@relayout)
    $(document).on("projectSelected", @onProjectSelected)
    $(document).on("modeChanged"    , @onModeChanged)
    @uis.prv_button     .on 'click',    @navigation.previousProject
    @uis.nxt_button     .on 'click',    @navigation.nextProject
    @uis.tour_button    .on 'click', => @navigation.setMode(MODE_TOUR)
    @uis.overview_button.on 'click', => @navigation.setMode(MODE_OVERVIEW)

    # resize
    @relayout()

  relayout: =>
    # usefull for the scrollbar:
    # set the description height to use the overflow: auto style
    description    = $($(".Panel .description").get(@navigation.mode)) # select the current description
    navigation_btn = $(@uis.navigation_btn.get(@navigation.mode))
    description.css
      height : $(window).height() - description.offset().top - navigation_btn.outerHeight(true)

  onProjectSelected: (e, project) =>
    if project?
      @uis.title       .html project.title
      @uis.location    .html project.recipient_condensed
      @uis.description .html project.description

  onModeChanged: (e, mode) =>
    @uis.intro         .toggleClass("hidden", mode != MODE_INTRO)
    @uis.single_project.toggleClass("hidden", mode != MODE_TOUR)
    @uis.start_overview.toggleClass("hidden", mode != MODE_START_OVERVIEW)
    @uis.overview      .toggleClass("hidden", mode != MODE_OVERVIEW)
    @relayout() # resize because the view has changed

# -----------------------------------------------------------------------------
#
#    AFRICA MAP
#
# -----------------------------------------------------------------------------
class AfricaMap

  CONFIG =
    svg_block_selector : ".africa-container"
    svg_height         : 500
    svg_width          : 500
    scale_range        : [6, 9]

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

# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 16-Jan-2014
# Last mod : 04-Feb-2014
# -----------------------------------------------------------------------------

MODE_INTRO          = 0
MODE_TOUR           = 1
MODE_START_OVERVIEW = 2
MODE_OVERVIEW_INTRO = 3
MODE_OVERVIEW       = 4

# -----------------------------------------------------------------------------
#
#    NAVIGATION
#
# -----------------------------------------------------------------------------
class Navigation

  CONFIG =
    urls :
      geojson          : "static/data/africa.json"
      tour             : "static/data/tour.json"
      overview         : "static/data/global_view.json"
      projects_details : "static/data/chart_aiddata.csv"

  constructor: ->
    @mode             = undefined
    @current_project  = undefined
    current_overview  = undefined
    @is_loading       = true
    # data (from csv)
    @data =
      projects         : undefined
      overview         : undefined
      projects_details : undefined
    # widgets
    @map   = undefined
    @panel = undefined
    # ui elements
    @uis =
      page              : $(".container:first")
      switch_mode_radio : $(".toggle-radio input[name=ab]")
    # bind event
    @uis.switch_mode_radio.on("click", @onSwitchRadioClick)

  init: =>
    q = queue()
    q
      .defer(d3.json, CONFIG.urls.geojson)
      .defer(d3.json, CONFIG.urls.tour)
      .defer(d3.json, CONFIG.urls.overview)
      .defer(d3.csv, CONFIG.urls.projects_details)
    # preload images 
    for file in files_to_preload
      q.defer(@loadImage, file)
    q.await(@loadedDataCallback)

  loadedDataCallback: (error, geojson, tour, overview, projects_details) =>
    @data.projects         = tour
    @data.overview         = overview
    # set a map for projects details with country as key
    @data.projects_details = d3.map()
    @data.projects_details.set(p.country, p) for p in projects_details
    # get the features from topojson
    geo_features = topojson.feature(geojson, geojson.objects.continent_Africa_subunits).features
    # instanciate widgets
    @map         = new AfricaMap(this, geo_features, @data.projects, @data.overview)
    @panel       = new Panel(this)
    @setMode(MODE_INTRO)
    # remove the loader
    @toggleLoading(false)

  toggleLoading:  (is_loading) =>
    @is_loading = is_loading or not @is_loading
    $(".container-full").toggleClass("on-loading", @is_loading)
    $(document).trigger("loading", @is_loading)

  setMode: (mode) =>
    if @mode != mode
      @mode = mode
      # set a project if the tour mode is selected
      if @mode == MODE_TOUR
        if @current_project?
          @setProject(@current_project)
        else
          @setProject(0)
      else
        @setProject(null)
      if @mode == MODE_OVERVIEW_INTRO
        @setOverview(null)
      # update the mode switcher radio
      if @mode == MODE_TOUR
        @uis.switch_mode_radio.prop('checked', false).filter("[value=tour]").prop('checked', true)
      else if @mode == MODE_OVERVIEW or @mode == MODE_OVERVIEW_INTRO
        @uis.switch_mode_radio.prop('checked', false).filter("[value=overview]").prop('checked', true)
      # trigger an event for the others widgets
      $(document).trigger("modeChanged", @mode)

  setProject: (project) =>
    """
    use this function to set a project.
    it will trigger a projectSelected event that all the other widget
    are able to bind.
    """
    # we need an interger as @current_project
    if project? and typeof(project) is "object"
      project = @data.projects.indexOf(project)
    if project != @current_project # if a new project is selected
      # save the state of the selected project
      @current_project = project
      # ensure the mode
      @setMode(MODE_TOUR) if project?
      # trigger a projectSelected with the selected project or null if no project is selected
      $(document).trigger("projectSelected", if @current_project? then @data.projects[@current_project] else null)

  setOverview: (country) =>
    """
    use this function to select a country in the overview mode.
    it will trigger an overviewSelected event that all the other widget
    are able to bind.
    """
    # we need an interger as @current_overview
    if country? and typeof(country) is "object"
      country = @data.overview.indexOf(country)
    if country != @current_overview # if a new country is selected
      # save the state of the selected project
      @current_overview = country
      # ensure the mode
      @setMode(MODE_OVERVIEW) if country?
      $(document).trigger("overviewSelected", if @current_overview? then @data.overview[@current_overview] else null)

  nextProject: =>
    if @hasNext()
      @setProject(@data.projects[@current_project + 1])
    else # if it's after the last project, we switch to the START_OVERVIEW mode
      @setMode(MODE_START_OVERVIEW)

  previousProject: =>
    if @hasPrevious()
      @setProject(@data.projects[@current_project - 1])
    else # if it's before the first project, we switch to the INTRO mode
      @setMode(MODE_INTRO)

  hasNext    : => @current_project < @data.projects.length - 1
  hasPrevious: => @current_project > 0

  onSwitchRadioClick: =>
    val = @uis.switch_mode_radio.filter(":checked").val()
    if val == "overview"
      @setMode(MODE_OVERVIEW_INTRO)
    else
      @setMode(MODE_INTRO)

  loadImage : (src, cb) =>
    img     = new Image()
    img.src = src
    img.onload = ->
      cb(null, img)
    img.onerror = ->
      cb('IMAGE ERROR', null)

# EOF

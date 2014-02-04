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
MODE_OVERVIEW       = 3

# -----------------------------------------------------------------------------
#
#    NAVIGATION
#
# -----------------------------------------------------------------------------
class Navigation

  CONFIG =
    urls :
      geojson  : "static/data/africa.json"
      tour     : "static/data/tour.json"
      overview : "static/data/global_view.json"

  constructor: ->
    @projects        = undefined
    @mode            = undefined
    @current_project = undefined

    @uis =
      page              : $(".container:first")
      switch_mode_radio : $(".toggle-radio input[name=ab]")

    # bind event
    @uis.switch_mode_radio.change(@onSwitchRadioChanged)

  start: =>
    queue()
      .defer(d3.json, CONFIG.urls.geojson)
      .defer(d3.json, CONFIG.urls.tour)
      .defer(d3.json, CONFIG.urls.overview)
      .await(@loadedDataCallback)

  loadedDataCallback: (error, geojson, tour, overview) =>
    @setMode(MODE_INTRO)
    @projects    = tour
    @overview    = overview
    geo_features = topojson.feature(geojson, geojson.objects.continent_Africa_subunits).features
    @map         = new AfricaMap(this, geo_features, @projects, @overview)
    @panel       = new Panel(this)

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
      # update the mode switcher radio
      if @mode == MODE_TOUR
        @uis.switch_mode_radio.prop('checked', false).filter("[value=tour]").prop('checked', true)
      else if @mode == MODE_OVERVIEW
        @uis.switch_mode_radio.prop('checked', false).filter("[value=overview]").prop('checked', true)
      # trigger an event for the others widgets
      $(document).trigger("modeChanged", @mode)

  setProject: (project) =>
    """
    use this function to set a project.
    it will trigger an projectSelected event that all the other widget
    are able to bind.
    """
    # we need an interger as @current_project
    if project? and typeof(project) is "object"
      project = @projects.indexOf(project)
    if project != @current_project
      # save the state of the selected project
      @current_project = project
      # ensure the mode
      @setMode(MODE_TOUR) unless not project?
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

  onSwitchRadioChanged: =>
    if @uis.switch_mode_radio.filter(":checked").val() == "overview"
      @setMode(MODE_OVERVIEW)
    else
      @setMode(MODE_INTRO)
# EOF

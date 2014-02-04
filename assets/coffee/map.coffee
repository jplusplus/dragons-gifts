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
# -----------------------------------------------------------------------------
#
#    AFRICA MAP
#
# -----------------------------------------------------------------------------
class AfricaMap

  CONFIG =
    svg_height                 : 500
    svg_width                  : 500
    initial_zoom               : 350
    close_zoom                 : 800
    initial_center             : [15, 0]
    scale_range_tour           : [6, 9]  # scale for compute the circle radius
    scale_range_overview       : [4, 15] # scale for compute the circle radius
    transition_map_duration    : 1500
    transition_circle_duration : 500
    transition_circle_ease     : "easeOutExpo"

  constructor: (navigation, countries, projects, overview) ->
    @navigation = navigation
    @countries  = countries
    @projects   = projects
    @overview   = overview

    # Create svg tag
    @svg = d3.select(".africa-container")
      .insert("svg", ":first-child")
      .attr("width", CONFIG.svg_width)
      .attr("height", CONFIG.svg_height)

    # Create projection
    @projection = d3.geo.mercator()
      .center(CONFIG.initial_center)
      .scale(CONFIG.initial_zoom)
      .translate([CONFIG.svg_width/2 - 40, CONFIG.svg_height/2])

    # Create the Africa path
    @path = d3.geo.path()
      .projection(@projection)

    @group = @svg.append("g")
    # Create the group of path and add graticule
    @groupPaths = @group.append("g")
      .attr("class", "all-path")

    @groupOverview = @group.append("g")
      .attr("class", "all-overview-points")

    @groupProject = @group.append("g")
      .attr("class", "all-project-points")

    @drawAfricaMap()
    @initProjectCircles()

    # Bind events
    $(document).on("modeChanged"    , @onModeChanged)
    $(document).on("projectSelected", @onProjectSelected)
    $(document).on("overviewSelected", @onOverviewSelected)

  drawAfricaMap: =>
    # Create every countries
    @groupPaths.selectAll("path")
      .data(@countries)
      .enter()
        .append("path")
        .attr("d", @path)

  drawCircles: (scale, radius_field_name="usd_defl", appearing_animatation=true) =>
    that = this
    @circles.each (d) ->
      d3.select(this)
        .attr("cx", (d) -> that.projection([d.lon, d.lat])[0])
        .attr("cy", (d) -> that.projection([d.lon, d.lat])[1])
      if appearing_animatation
        d3.select(this)
          .attr("r" , 0) # init rayon before transition
          .transition()
            .ease(CONFIG.transition_circle_ease)
            .duration(CONFIG.transition_circle_duration)
            .delay(CONFIG.transition_map_duration)
              .attr("r" , (d) -> scale(parseFloat(d[radius_field_name])))
      else
       d3.select(this)
        .attr("r" , (d) -> scale(parseFloat(d[radius_field_name])))

  initProjectCircles: =>
    that = this
    # compute scale
    values = @projects.map((d) -> parseFloat(d.usd_defl))
    @project_scale  = d3.scale.linear()
      .domain([Math.min.apply(Math, values), Math.max.apply(Math, values)])
      .range(CONFIG.scale_range_tour)
    #remove previous circles
    @groupOverview.selectAll("circle").transition()
      .ease(CONFIG.transition_circle_ease)
      .duration(CONFIG.transition_circle_duration)
      .attr("r", 0).remove()
    # create circles
    @circles = @groupProject.selectAll("circle")
      .data(@projects)
    @circles.enter()
      .append("circle")
        .on 'click', (d) ->
          that.navigation.setProject(d)
          # $(this).trigger("mouseout") # hide the tooltip
    # postioning cirlces
    @drawCircles(@project_scale)
    # tooltip
    @circles.each (d) ->
      $(d3.select(this)).qtip
        content: "#{d.title}<br/>#{d.recipient_oecd_name}"
        style  : 'qtip-dark'

  onProjectSelected: (e, project) =>
    # select a cirlce
    @circles.each (d, i) ->
      d3.select(this).classed("active", project is d)
    # zoom
    selected = @circles.filter((d) -> d is project)
    if project? # zoom
      center = [project.lon, project.lat]
      @projection.center(center).scale(CONFIG.close_zoom)
      @groupPaths.selectAll("path")
        .transition().duration(CONFIG.transition_map_duration)
        .attr("d", @path)
      @drawCircles(@project_scale, "usd_defl")
      $(selected).trigger("mouseover")
    else # dezoom
      @projection.center(CONFIG.initial_center).scale(CONFIG.initial_zoom)
      @groupPaths.selectAll("path")
        .transition().duration(CONFIG.transition_map_duration)
        .attr("d", @path)
      @drawCircles(@project_scale)

  onOverviewSelected: (e, overview) =>
    console.log "onOverviewSelected"

  initOverviewCircles: =>
    that = this
    # compute scale
    values = @overview.map((d) -> parseFloat(d.USD))
    scale  = d3.scale.linear()
      .domain([Math.min.apply(Math, values), Math.max.apply(Math, values)])
      .range(CONFIG.scale_range_overview)

    #remove previous circles
    @groupProject.selectAll("circle").transition()
      .ease(CONFIG.transition_circle_ease)
      .duration(CONFIG.transition_circle_duration)
      .attr("r", 0).remove()
    @circles = @groupOverview.selectAll("circle")
      .data(@overview)
    @circles.enter()
      .append("circle")
    @drawCircles(scale, "USD")

  onModeChanged: (e, mode) =>
    if mode == MODE_OVERVIEW
      @initOverviewCircles()
    else
      @initProjectCircles()

# EOF

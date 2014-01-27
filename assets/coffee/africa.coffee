class Africa
  # Define default config
  config =
    # SVG
    svgBlockSelector: ".africa-container"
    svgHeight: 500
    svgWidth: 500

    
    # DATA RESSOURCES URL
    urlWorldTopojson: "static/data/world-110m2.json"
    urlCities: "static/data/cities.csv"


  # Declare variables
  svg = projection = path = groupPaths = null

  currentRotation = config.globeDefaultRotation     # Store the current rotation of the globe
  currentLevel    = 1                               # Store the current level (1 or 2)
  manualRotationActivated = true                    # If true, mouse move calculation with me
                                                    # activated for manual rotate

  groupPathsSelection = {}    # Store the groupPath selection of element to avoid reselecting DOM

  #
  # Contruct class instance
  #
  constructor: (overridingConfig = {}) ->
    # Override config with new parameters
    config = _.defaults(overridingConfig, config)

    # Define initialScale
    config.initialScale = config.svgHeight * 0.5


  #
  # Initialize SVG context + sphere
  #
  initSVG: () =>

    # Create svg tag
    svg = d3.select(config.svgBlockSelector)
            .insert("svg", ":first-child")
            .attr("width", config.svgWidth)
            .attr("height", config.svgHeight)


    # Create projection
    projection = d3.geo.mercator()
                  .center([0, 5])
                  .scale(350)
                  .rotate([-55,5])

    # Create the Africa path
    path = d3.geo.path()
             .projection(projection)

    # Create the group of path and add graticule
    groupPaths = svg.append("g")
                    .attr("class", "all-path")

    @groupPoints = svg.append("g")
                    .attr("class", "all-points")



  #
  # Load and display data
  #
  start: () =>
    @initSVG()
    queue()
      .defer(d3.json, config.urlWorldTopojson)
      .defer(d3.csv, config.urlCities)

      .await(this.loadedDataCallback)


  #
  # Compute data after loading :
  #  - Build country paths
  #
  loadedDataCallback: (error, worldTopo, cities) =>

    # Add countries to globe
    countries = topojson.object(worldTopo, worldTopo.objects.countries).geometries

    # Create every countries
    groupPaths.selectAll("path")
                .data(countries)
                .enter()
                  .append("path")
                  .attr("d", path)

    @groupPoints.selectAll("circle")
    .data(cities)
    .enter()
    .append("circle")
    .attr("cx", (d) ->
      projection([d.lon, d.lat])[0]
    ).attr("cy", (d) ->
      projection([d.lon, d.lat])[1]
    )
    .attr("r", 5)
    .style("fill", "red")
          

globe = new Africa()
globe.start()
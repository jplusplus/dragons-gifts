# Encoding: utf-8
# -----------------------------------------------------------------------------
# Project : Dragons Gifts
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
#          Jacopo Ottaviani                             <j.ottaviani@gmail.com>
# -----------------------------------------------------------------------------
# License : GNU Lesser General Public License
# -----------------------------------------------------------------------------
# Creation : 04-Feb-2014
# Last mod : 04-Feb-2014
# -----------------------------------------------------------------------------
#
#    CHART
#
# -----------------------------------------------------------------------------

class Chart

  constructor: ->
    @ui = ".chart"

  render: (details) =>
    # define dimensions of svg
    h = 200
    w = 290

    # parent svg element will contain the chart
    d3.select(@ui).select("svg").remove()

    chart = d3.select(@ui)
      .append("svg")
      .attr("width", w)
      .attr("height", h)

    dataset = 
      "Transport/Comm."   : +details.transport
      "Agriculture/Water" : +details.agriculture
      "Education/Culture" : +details.education
      "Energy"            : +details.energy
      "Government"        : +details.govt
      "Health/Emerg."     : +details.health
      "Other"             : +details.other
      "Mining/Industry"   : +details.industry

    barwidth     = w / 8
    spacing      = 1
    chartPadding = 70
    chartTop     = 60
    chartBottom  = h - chartPadding
    chartRight   = w - 5
    barLabels    = _.keys(dataset)
    max          = Math.max.apply(Math, _.values(dataset))

    x = d3.scale.ordinal()
      .rangeRoundBands([0, w], .1)

    y = d3.scale.linear()
      .range([h, 0])

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .tickFormat(formatPercent)

    dataset = _.pairs(dataset)

    # yScale       = d3.scale.linear().domain([
    #   0
    #   max
    # ]).range([
    #   chartBottom
    #   chartPadding - chartTop
    # ]).nice()

    # xScale = d3.scale.ordinal().domain(barLabels).rangeRoundBands([
    #   chartPadding
    #   chartRight
    # ], 0.1)

    # yAxis = d3.svg.axis().scale(yScale).orient("left")
    # xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(0)


    # create bars
    # returns empty selection
    # parses & counts data
    # binds data to placeholders
    # creates a rect svg element for every datum
    # bar
    # position of the top of each bar
    
    # attach event listener to each bar for mouseover
    # adds a "smoothing" animation to the transition
    # set the duration of the transition in ms (default: 250)
    # chart.selectAll("rect")
    #   .data(dataset)
    #   .enter()
    #   .append("rect")
    #   .attr("x", (d, i) -> xScale i)
    #   .attr("y", (d) -> yScale d[1])
    #   .attr("width", xScale.rangeBand())
    #   .attr("height", (d) -> chartBottom - yScale(d[1]))
    #   .attr("fill", "red")
    #   .on "mouseover", (d) ->
    #     d3.select(this)
    #       .transition()
    #       .duration(200)
    #       .attr "fill", "darkred"
    #       chart.append("text")
    #         .text(d[1])
    #         .attr("x", xScale(dataset.indexOf(d)) + (xScale.rangeBand() / 2))
    #         .attr("y", yScale(d[1]) + 15 ) 
    #         .attr("class", "value_bar")

    #   .on "mouseout", (d) ->
    #     d3.select(this)
    #       .transition()
    #       .duration(200)
    #       .attr "fill", "red"
    #     chart.select("text.value_bar").remove()


    # # multiple attributes may be passed in as an object
    # chart.selectAll("text")
    #   .data(dataset)
    #   .enter()
    #     .append("text")
    #     .attr("x", (d) -> xScale(d[0]) + xScale.rangeBand() / 2)
    #     .attr("y", (d) -> h - yScale(d[1]))
    
    # # after chart code, set up group element for axis
    # # use transformation to adjust position of axis
    # y_axis = chart.append("g").attr("class", "axis").attr("transform", "translate(" + chartPadding + ",0)")

    # # generate y Axis within group using yAxis function
    # yAxis y_axis
    # # push to bottom

    # chart.append("g")
    #    .attr("class", "axis xAxis")
    #    .attr("transform", "translate(0," + chartBottom + ")")
    #    .call(xAxis)
    #      .selectAll('text')
    #         .style('text-anchor','end')
    #         .attr('transform','rotate(-35)')


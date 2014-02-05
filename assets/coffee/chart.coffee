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

    # create svg element
    # parent svg element will contain the chart
    d3.select(@ui).select("svg").remove()
    chart = d3.select(@ui).append("svg").attr("width", w).attr("height", h)


    # load data from a CSV file
    # d3.csv "../static/data/chart_aiddata.csv", ((d) ->
    #   if d.country is country_name
    #     "Transport/Comm.": +d.transport
    #     "Agriculture/Water": +d.agriculture
    #     "Education/Culture": +d.education
    #     Energy: +d.energy
    #     Government: +d.govt
    #     "Health/Emerg.": +d.health
    #     Other: +d.other
    #     "Mining/Industry": +d.industry

    #total: +d.total
    # ), (dataset) ->
    # code to generate chart goes here

    dataset = d3.entries(dataset[0])
    barwidth = w / 8
    spacing = 1
    chartPadding = 70
    chartTop = 60
    chartBottom = h - chartPadding
    chartRight = w - 5
    barLabels = dataset.map((datum) ->
      datum.key
    )
    max = Math.max.apply(Math, dataset.map((datum) ->
      datum.value
    ))
    yScale = d3.scale.linear().domain([
      0
      max
    ]).range([
      chartBottom
      chartPadding - chartTop
    ]).nice()
    xScale = d3.scale.ordinal().domain(barLabels).rangeRoundBands([
      chartPadding
      chartRight
    ], 0.1)
    yAxis = d3.svg.axis().scale(yScale).orient("left")
    xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(0)
    
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
    chart.selectAll("rect").data(dataset).enter().append("rect").attr("x", (d) ->
      xScale d.key
    ).attr("y", (d) ->
      yScale d.value
    ).attr("width", xScale.rangeBand()).attr("height", (d) ->
      chartBottom - yScale(d.value)
    ).attr("fill", "red").on("mouseover", (d) ->
      d3.select(this).transition().duration(200).attr "fill", "darkred"
      showValue d
      return
    ).on "mouseout", (d) ->
      # adds a "smoothing" animation to the transition
      # set the duration of the transition in ms (default: 250)
      d3.select(this).transition().duration(200).attr "fill", "red"
      hideValue()
      return

    showValue = (d) ->
      chart.append("text").text(d.value).attr
        x: xScale(d.key) + (xScale.rangeBand() / 2)
        y: yScale(d.value) + 15
        class: "value_bar"

      return

    hideValue = ->
      chart.select("text.value_bar").remove()
      return

    
    #.text(function(d){
    #  return d.value;
    #})
    # multiple attributes may be passed in as an object
    chart.selectAll("text").data(dataset).enter().append("text").attr
      x: (d) ->
        xScale(d.key) + xScale.rangeBand() / 2

      y: (d) ->
        h - yScale(d.value)

    
    # after chart code, set up group element for axis
    # use transformation to adjust position of axis
    y_axis = chart.append("g").attr("class", "axis").attr("transform", "translate(" + chartPadding + ",0)")
    
    # generate y Axis within group using yAxis function
    yAxis y_axis
    # push to bottom
    chart.append("g").attr("class", "axis xAxis").attr("transform", "translate(0," + chartBottom + ")").call xAxis
    chart.selectAll(".xAxis").selectAll("text").style("text-anchor", "end").attr "transform", "rotate(-45)"

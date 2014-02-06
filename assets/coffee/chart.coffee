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

    margin = {top: 20, right: 0, bottom: 100, left: 50}
    w = 300 - margin.left - margin.right
    h = 250 - margin.top - margin.bottom


    # parent svg element will contain the chart
    d3.select(@ui).select("svg").remove()
    chart = d3.select(@ui)
      .append("svg")
      .attr("width", w + margin.left + margin.right)
      .attr("height", h + margin.top + margin.bottom)
      .attr("style","background-color:white")
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    dataset = {}
    dataset["Transport/Comm."] = +details.transport
    dataset["Agriculture/Water"] = +details.agriculture
    dataset["Education/Culture"] = +details.education
    dataset["Energy"] = +details.energy
    dataset["Government"] = +details.govt
    dataset["Health/Emerg."] = +details.health
    dataset["Other"] = +details.other
    dataset["Mining/Industry"] = +details.industry
    
    barLabels = _.keys(dataset)

    max = Math.max.apply(Math, _.values(dataset))

    formatxAxis = d3.format('.0f');

    x = d3.scale.ordinal().rangeRoundBands([0, w],.1)
    y = d3.scale.linear().range([h,0])

    xAxis = d3.svg.axis().scale(x).orient("bottom").tickSize(0)
    yAxis = d3.svg.axis().scale(y).orient("left").tickFormat(formatxAxis).ticks(5)

    x.domain(_.keys(dataset))
    y.domain([0, max])

    chart.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + h + ")")
      .call(xAxis)
        .selectAll('text')
        .style('text-anchor','end')
        .attr('transform','rotate(-45)')

    chart.append("g")
      .attr("class", "y axis")
      .call(yAxis)

    chart.selectAll(".bar")
      .data(_.pairs(dataset))
        .enter()
        .append("rect")
        .attr("class","bar")
        .attr("x", (d) -> x(d[0]))
        .attr("width", x.rangeBand())
        .attr("y", (d) -> y(d[1]))
        .attr("height", (d) -> h - y(d[1]))
        .attr("fill","purple")
      .on('mouseover', (d) -> 
        d3.select(this)
        .transition()
        .duration(500)
        .attr('fill','red')
        
        chart.append('text')
        .text(d[1])
        .attr('x', x(d[0]) + x.rangeBand() / 2 )
        .attr('y', y(d[1]) + 15)
        .attr('class', 'value_bar')
      )
      .on('mouseout', (d) ->
        d3.select(this)
        .transition()
        .duration(500)
        .attr('fill','purple')

        chart.select('text.value_bar').remove()

      ) 


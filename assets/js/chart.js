// define dimensions of svg
var h = 300,
	w = 300;

// create svg element
var chart = d3.select('#single_country_chart')
	       		.append('svg') // parent svg element will contain the chart
          		.attr('width', w)
           		.attr('height', h);

// load data from a CSV file
d3.csv('../static/data/chart_aiddata.csv', function(d) {
        
		if (d.country == "Ghana") {
	        return {
		            transport: +d.transport,
					agriculture: +d.agriculture,
					education: +d.education,
					energy: +d.energy,
					govt: +d.govt,
					health: +d.health,
		            other: +d.other,
		            industry: +d.industry
		            //total: +d.total
		        }
        };

    },
    
    function(dataset) {

        // code to generate chart goes here

        dataset = d3.entries(dataset[0]);

		var barwidth = w / 8;
		var spacing = 1;
		var chartPadding = 50;
		var chartBottom = h - chartPadding;  
		var chartRight = w - chartPadding;  

		var barLabels = dataset.map(function(datum){
            return datum.key;
        });

        var max = Math.max.apply(Math, dataset.map( function (datum) {return datum.value; } ));

        var yScale = d3.scale.linear()
        	.domain([0,max])
        	.range([chartBottom,chartPadding])
        	.nice();

		var xScale = d3.scale.ordinal()
                     .domain( barLabels )
                     .rangeRoundBands([chartPadding,chartRight], 0.1);


		var yAxis = d3.svg.axis()
		                  .scale(yScale)
		                  .orient('left');


		var xAxis = d3.svg.axis()
		                  .scale(xScale)
		                  .orient('bottom')
		                  .tickSize(0);





		// create bars
		chart.selectAll('rect')  // returns empty selection
		     .data(dataset)      // parses & counts data
		     .enter()            // binds data to placeholders
		     .append('rect')     // creates a rect svg element for every datum
		     .attr('x',function(d) {
                 	return xScale(d.key);    // bar
		      })
		     .attr('y',function(d){
                 return yScale(d.value); // position of the top of each bar
		      })
		     .attr('width', xScale.rangeBand())
		     .attr('height',function(d){
		        return chartBottom - yScale(d.value);
		      })
		     .attr('fill','red')
		          // attach event listener to each bar for mouseover
			 .on('mouseover',function(d){
			      d3.select(this)
			        .transition()  // adds a "smoothing" animation to the transition
      				.duration(200) // set the duration of the transition in ms (default: 250)
			        .attr('fill','darkred');
			        showValue(d);
			 })
			 .on('mouseout',function(d){
			    d3.select(this)
			      .transition()  // adds a "smoothing" animation to the transition
      			  .duration(200) // set the duration of the transition in ms (default: 250)
			      .attr('fill','red');
			      hideValue();
			 });


			var showValue = function(d) {
				console.log((xScale.rangeBand() / 2));
				chart.append('text')
			 		.text(d.value)
			 		.attr({
			     	'x': xScale(d.key) + (xScale.rangeBand() / 2),
			     	'y': yScale(d.value) + 15,
			     	'class': 'value_bar'
			 	});
			}

			var hideValue = function() {
				chart.select('text.value_bar').remove();
			}

		chart.selectAll('text')
				.data(dataset)
				.enter()
				.append('text')
				//.text(function(d){
				// 	return d.value;
				//})
				// multiple attributes may be passed in as an object
				.attr({
					'x': function(d){ return xScale(d.key) + xScale.rangeBand() / 2},
					'y': function(d){ return h - yScale(d.value) },
					'font-family': 'sans-serif',
					'font-size': '13px',
					'font-weight': 'bold',
					'fill': 'black',
					'text-anchor': 'middle'
				});

		// after chart code, set up group element for axis
		// use transformation to adjust position of axis
		y_axis = chart.append('g')
		            .attr('class','axis')
		            .attr('transform','translate(' + chartPadding + ',0)');

		// generate y Axis within group using yAxis function
		yAxis(y_axis);

		chart.append('g')
		     .attr('class', 'axis xAxis')
		     .attr('transform','translate(0,' + chartBottom + ')')  // push to bottom
		     .call(xAxis);

		chart.selectAll('.xAxis')
		     .selectAll('text')
        	 .style('text-anchor','end')
        	 .attr('transform','rotate(-45)');
		  
	}
);
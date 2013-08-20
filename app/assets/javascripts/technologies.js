// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function chart_from_data_url(url) {
    console.log("Fetching JSON data from "+url);
    $.ajax({
        url: url,
        success: function(data) {
            render_chart(data);
        },
        error: function() {
            alert("Error loading "+url);
        }
    });
}


function render_chart(data) {
    console.log(data);

    var cdata = [{
        key: 'so',
        values: _.map(data,function(d) {
            return {
                "month": d.day,
                "value": d.val,
            }
        })
    }];
    console.log(cdata);

    nv.addGraph(function() {
        var chart = nv.models.discreteBarChart()
             .x(function(d) { return d.month })
             .y(function(d) { return d.value })
             ;

        chart.xAxis
            .tickFormat(d3.format(',f'));

        chart.yAxis
            .tickFormat(d3.format(',.1f'));

        d3.select('#chart svg')
            .datum(cdata)
          .transition().duration(500).call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    });
}


// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


function SaneDate() {};

/**
 * Parses a string like "2013-04-15" just as far as year and month, into a 
 * javascript date object in local timezone.
 */
SaneDate.parseYearMonth = function(strval) {
    var parts = strval.split("-");
    var year = Number(parts[0]);
    var month = Number(parts[1]);
    return new Date(year,month-1,1);
}

SaneDate.shortString = function(date) {
    var month_names = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
    ]

    return month_names[date.getMonth()] + " " + this.getFullYear();
}


function chart_from_data_url(url) {
    console.log("Fetching JSON data from "+url);
    d3.json(url,function(data) {
        console.log("raw",data);
        data = preprocess(data);
        console.log("preprocessed",data);
        render_chart(data);
    });
}


// Fills in zeros.
function preprocess(data) {
    var dates = _.map(data,function(datum) { return SaneDate.parseYearMonth(datum.day) } );
    var mindate = _.min(dates);
    var maxdate = _.max(dates);

    // build a hash mapping dates with non-zero values to their values
    var date_to_val = {}; 
    _.each(data,function(datum) {
        date_to_val[SaneDate.parseYearMonth(datum.day)] = datum.val;
    });

    // Build the array, with zeros in all missing months
    var out = []
    for( var i=mindate; i<=maxdate; i.setMonth(i.getMonth()+1) ) {
        var d = new Date(i);  // clone the object
        out.push({
            date: d,
            value: date_to_val[d] ? date_to_val[d] : 0
        });
    }
    return out;
}


function render_chart(data) {
    console.log(data);

    var cdata = [{
        key: 'so',
        values: data
    }];
    console.log(cdata);

    nv.addGraph(function() {
        //var chart = nv.models.lineChart()
        var chart = nv.models.stackedAreaChart()
        //var chart = nv.models.discreteBarChart()
             .x(function(d) { return d.date })
             .y(function(d) { return d.value })
             ;

        chart.xAxis
            .tickFormat(function(d) { return d3.time.format('%b %Y')(new Date(d)) });


        chart.yAxis
            .tickFormat(d3.format(',.0f'));

        d3.select('#chart svg')
            .datum(cdata)
          .transition().duration(500).call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    });
}


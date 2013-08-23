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


/* Takes an arbitrary number of metric data sets as arguments.
   Returns an array of [mindate, maxdate]
 */
function dateRange() {
    var all_dates = [];
    for( var i in arguments ) {
        var data = arguments[i];
        var these_dates = _.map(data,function(datum) { return SaneDate.parseYearMonth(datum.day) } );
        all_dates = all_dates.concat(these_dates);
    }
    var mindate = _.min(all_dates);
    var maxdate = _.max(all_dates);
    return [mindate, maxdate];
}


/** Returns an array of date,value objects with zeros for any missing dates in the range.
 */
function fillInZeros(daterange, data) {
    var mindate = new Date(daterange[0]);  // clone
    var maxdate = new Date(daterange[1]);  // clone

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


/* Fills in zeros for months that have nothing.
*/
function preprocessOne(data) {
    var range = dateRange(data);
    return fillInZeros(range, data);
}


function render_chart(data) {
    console.log(data);

    var cdata = [{
        key: 'so',
        values: data
    }];
    console.log(cdata);

    render_chart_many(cdata);
}

function render_chart_many(cdata, usemulti) {
    nv.addGraph(function() {
        var chartMethod = usemulti ? nv.models.multiBarChart : nv.models.stackedAreaChart;
        // chartMethod = nv.models.lineChart;
        var chart = chartMethod()
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


function chart_from_data_url(url) {
    console.log("Fetching JSON data from "+url);
    d3.json(url,function(data) {
        console.log("raw",data);
        data = preprocessOne(data);
        console.log("preprocessed",data);
        render_chart(data);
        $("#chart .note").html('');
    });
}


function comparison_chart(descriptors) {
    /* descriptors is an Array of {url: 'http://...', name: 'java'} objects.
    */
    var alldata = {};  // store here when fetched.
    var num_to_fetch = descriptors.length;
    function downloaded(data, name) {
        alldata[name] = data;
        num_to_fetch--;
        if( num_to_fetch ) {
            console.log("Still need to fetch " + num_to_fetch + " more data sets before charting.");
            return;
        }
        console.log("All downloaded", alldata);

        // Do the real work to render all the data!
        var range = dateRange.apply({},_.values(alldata));
        var cdata = [];
        for( var name in alldata ) {
            cdata.push({
                key: name,
                values: fillInZeros(range, alldata[name])
            });
        }
        render_chart_many(cdata, true);
    };

    for( i in descriptors ) {
        function fetchOne(url,name) {
            d3.json(url, function(data) {
                downloaded(data, name);
            });
        }
        var descriptor = descriptors[i];
        console.log("Fetching "+descriptor.name+" data from "+descriptor.url);
        fetchOne(descriptor.url, descriptor.name); // avoid a classic closure trap
    }
}



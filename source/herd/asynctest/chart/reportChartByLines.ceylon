

"Reports charts writing line by line:  
 * line with chart title, category title and value title
 * line with plot titles
 * lines with points for each plot
 
 Each item is separated using [[ReportFormat.delimiter]] (see [[defaultFormat]]).    
 Numbers are reported using language [[formatFloat]]
 with given decimalPlaces (see [[defaultFormat]]).  
 "
since( "0.3.0" )
by( "Lis" )
shared void reportChartByLines (
	"Default format used if no format specified in chart." ReportFormat defaultFormat,
	"Charts to be reported." Chart[] charts,
	"Function used to write a line." void writeLine( String line )
) {
	for ( chart in charts ) {
		// format used for the current chart
		ReportFormat format = if ( exists f = chart.format ) then f else defaultFormat;
		
		// write and empty line
		writeLine( "" );
		
		// write chart title, category and value titles
		writeLine (
			"'chart':" + format.delimiter + chart.title + format.delimiter
			+ "'category':" + format.delimiter + chart.categoryTitle + format.delimiter
			+ "'value':" + format.delimiter + chart.valueTitle
		);
		
		// write plot titles
		StringBuilder builder = StringBuilder();
		Integer delimSize = format.delimiter.size;
		for ( plot in chart.plots ) {
			builder.append( plot.title );
			builder.append( format.delimiter );
			builder.append( format.delimiter );
		}
		variable String line = builder.string;
		while ( line.endsWith( format.delimiter ) ) {
			line = line.spanTo( line.size - delimSize - 1 );
		}
		writeLine( line );
		
		// write plot points
		if ( exists maxLines = max( {for ( plot in chart.plots ) plot.points.size} ) ) {
			variable Integer current = 0;
			while ( current < maxLines ) {
				builder.clear();
				for ( plot in chart.plots ) {
					if ( exists pt = plot.points[current] ) {
						builder.append (
							Float.format (
								pt.category, format.minCategoryDecimalPlaces, format.maxCategoryDecimalPlaces
							)
						);
						builder.append( format.delimiter );
						builder.append (
							Float.format (
								pt.val, format.minValueDecimalPlaces, format.maxValueDecimalPlaces
							)
						);
						builder.append( format.delimiter );
					}
					else {
						builder.append( format.delimiter );
						builder.append( format.delimiter );
					}
				}
				line = builder.string;
				while ( line.endsWith( format.delimiter ) ) {
					line = line.spanTo( line.size - delimSize - 1 );
				}
				writeLine( line );
				current ++;
			}
		}
		
	}
}


"Chart as axis definitions and a list of plots."
since( "0.3.0" )
by( "Lis" )
shared class Chart (
	"Chart title." shared String title,
	"Title of category axis." shared String categoryTitle,
	"Title of value axis." shared String valueTitle,
	"Plots the chart contains." shared Plot[] plots,
	"Optional format to be used to report this chart" shared ReportFormat? format = null
) {
	
	"Returns chart bound as union of bounds of plots."
	see( `function Plot.bounds` )
	shared Rectangle bounds() {
		if ( exists first = plots.first ) {
			variable Rectangle ret = first.bounds();
			for ( plot in plots.rest ) {
				ret = ret.union( plot.bounds() );
			}
			return ret;
		}
		else {
			return Rectangle( 0.0, 0.0, 0.0, 0.0 );
		}
	}
	
	
	shared actual String string {
		StringBuilder plotTitles = StringBuilder();
		variable Integer index = 0;
		Integer lastIndex = plots.size - 1;
		String delim = ", ";
		for ( plot in plots ) {
			plotTitles.append( "'" );
			plotTitles.append( plot.title );
			plotTitles.append( "'" );
			if ( index != lastIndex ) {
				plotTitles.append( delim );
			}
			index ++;
		}
		return "Chart '``title``' with category '``categoryTitle``', value '``valueTitle``' and plots: ``plotTitles.string``";
	}
	
}

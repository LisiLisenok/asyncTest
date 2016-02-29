
"Description of a chart:
 * title
 * category axis title
 * value axis title
 * plot titles
 "
by( "Lis" )
shared class ChartDescription (
	"Chart title." shared String chartTitle,
	"Title of category axis." shared String categoryTitle,
	"Title of value axis." shared String valueTitle,
	"A list of plot titles the chart contains." shared String[] plotTitles,
	"Optional format to be used to report the chart" shared ReportFormat? format = null
) {
	
	shared actual String string {
		StringBuilder plotBuilder = StringBuilder();
		variable Integer index = 0;
		Integer lastIndex = plotTitles.size - 1;
		String delim = ", ";
		for ( plot in plotTitles ) {
			plotBuilder.append( "'" );
			plotBuilder.append( plot );
			plotBuilder.append( "'" );
			if ( index != lastIndex ) {
				plotBuilder.append( delim );
			}
			index ++;
		}
		return "ChartDescription '``chartTitle``' with category '``categoryTitle``', value '``valueTitle``' and plots: ``plotBuilder.string``";
	}
	
}

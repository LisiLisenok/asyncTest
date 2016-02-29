import herd.asynctest {

	TestInitContext
}
import ceylon.collection {

	ArrayList
}


"Performs charts initialization.  
 Stores [[Plotter]]'s on initialization context with name 'chartTitle-plotTitle'.  
 Retrieving plotters from test context:
 
 		AsyncTestContext context...
 		if (exists plotter = context.get<Plotter>(\"'chartTitle-plotTitle'\")) {
 			plotter.addPoint(x, y);
 			...
 		}
 		else {
 			// report on error
 		}
 		
 When test run is finished reports the charts to [[reporter]].  
 "
by( "Lis" )
shared void initializeCharts (
	"Context to store initialized plotters." TestInitContext context,
	"Description of charts to be initialized" ChartDescription[] charts,
	"Reporter to report with charts when test run is finished." Reporter reporter
) {
	ArrayList<ChartBuilder> builders = ArrayList<ChartBuilder>();
	String delim = "-";
	for ( chart in charts ) {
		ChartBuilder builder = ChartBuilder( chart.chartTitle, chart.categoryTitle, chart.valueTitle, chart.format );
		String prefix = chart.chartTitle + delim;
		for ( plot in chart.plotTitles ) {
			context.put<Plotter>( prefix + plot, builder.addPlot( plot ) );
		}
		builders.add( builder );
	}
	context.addTestRunFinishedCallback (
		() {
			reporter.report( [for ( builder in builders ) builder.build()] );
		}
	);
}

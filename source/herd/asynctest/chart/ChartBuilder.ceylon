import ceylon.collection {

	HashMap
}


"Builds a chart."
by( "Lis" )
shared class ChartBuilder (
	"Chart title." shared String chartTitle,
	"Title of category axis." shared String categoryTitle,
	"Title of value axis." shared String valueTitle,
	"Optional format to be used to report built chart" shared ReportFormat? format = null
) {
	
	HashMap<String, PlotBuilder> builders = HashMap<String, PlotBuilder>(); 
	
	
	"Returns previously added plotter by its title."
	see( `function addPlot` )
	shared Plotter? getPlotter( "Plotter title." String title ) => builders.get( title );
	
	"Adds new plot to the chart."
	shared Plotter addPlot (
		"Plot title or name." String title
	) {
		value builder = PlotBuilder( title );
		builders.put( title, builder );
		return builder;
	}
	
	"Builds the chart."
	shared Chart build()
			=> Chart (
				chartTitle, categoryTitle, valueTitle,
				[ for ( builder in builders.items ) builder.plot() ],
				format
			);
	
}

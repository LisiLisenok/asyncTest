"
 [[Chart]] is a set of plots, where each plot is a sequence of 2D points, [[Plot]].  
 Chart may have title, names of each axis and optional format used by report processor ([[ReportFormat]]).
 Plot also may have title.  
 [[Plotter]] is used to fill in plot.  
 
 The charts may be used to represent some test results, for example,
 chart of running time vs total numer of items in array for sorting function.
 
 Reporters can be used to human-friendly representation of charts.
 Available reporters:
 * [[CombinedReporter]] - reports to a given list of reporters
 * [[ConsoleReporter]] - reports to console
 * [[CSVReporter]] - reports to a file
 
 Another reporter can be implemented using [[Reporter]] interface.
 
 ### Usage example
 
 		Reporter plotReporter = CombinedReporter {
 			ConsoleReporter (
 				ReportFormat(\", \", 0, 0, 0, 0)
 			),
 			CSVReporter (
 				ReportFormat(\", \", 0, 0, 0, 0),
 				\"../report.csv\",
 				true
 			)
 		};
 
 		ChartBuilder builder = ChartBuilder(\"title\", \"category\", \"value\");
 		Plotter plotter1 = builder.addPlot(\"plot 1\");
 		Plotter plotter2 = builder.addPlot(\"plot 2\");

 		plotter1.addPoint( 1.0, 1.0 );
 		...
 		plotter2.addPoint( 1.0, 1.0 );
 		...
 		plotReporter.report(builder.build());
 
 
 --------------------------------------------
 "
since( "0.3.0" ) by( "Lis" )
shared package herd.asynctest.chart;

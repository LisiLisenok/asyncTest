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
 
 Recommended usage:
 * within test initializer (see [[herd.asynctest::init]] annotation)
 	* create [[ChartBuilder]]
 	* add plotters using [[ChartBuilder.addPlot]]
 	* store the plotters on the initialization context - [[herd.asynctest::TestInitContext.put]]
 	* create a reporter - object which satisfies [[Reporter]] interface
 	* add test run finishing callback - [[herd.asynctest::TestInitContext.addTestRunFinishedCallback]]
      which creates charts [[ChartBuilder.build]] and reports them to the given reporter
 * within test functions
 	* retrieve required [[Plotter]] using [[herd.asynctest::AsyncTestContext.get]]
 	* plot to the [[Plotter]]
 
 >[[initializeCharts]] helps to do all operations within test initializer.
 
 "
by( "Lis" )
shared package herd.asynctest.chart;

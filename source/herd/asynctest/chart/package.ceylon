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
 
 --------------------------------------------
 "
by( "Lis" )
shared package herd.asynctest.chart;

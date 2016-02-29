import herd.asynctest {

	TestInitContext
}
import herd.asynctest.chart {

	Reporter,
	ConsoleReporter,
	ReportFormat,
	initializeCharts,
	ChartDescription,
	CombinedReporter,
	CSVReporter
}
import ceylon.test {

	parameters
}


"Reporter used by `plotInitialization`"
shared [Reporter] generalReporter = [
	CombinedReporter {	
		ConsoleReporter (
			ReportFormat( ", ", 0, 0, 0, 0 )
		),
		CSVReporter (
			ReportFormat( ", ", 0, 0, 0, 0 ),
			"../report.csv",
			true
		)
	}
];


"Performs plots initialization."
parameters( `value generalReporter` )
shared void plotInitialization( TestInitContext context, Reporter reporter ) {
	initializeCharts (
		context,
		[
			ChartDescription (
				titles.put, titles.categoryTitle, titles.valTitle,
				[titles.ceylonHashMap, titles.ceylonTreeMap, titles.javaHashMap, titles.javaTreeMap]
			),
			ChartDescription (
				titles.get, titles.categoryTitle, titles.valTitle,
				[titles.ceylonHashMap, titles.ceylonTreeMap, titles.javaHashMap, titles.javaTreeMap]
			),
			ChartDescription (
				titles.remove, titles.categoryTitle, titles.valTitle,
				[titles.ceylonHashMap, titles.ceylonTreeMap, titles.javaHashMap, titles.javaTreeMap]
			),
			ChartDescription (
				titles.hashMapRatios, titles.categoryTitle, titles.valTitle,
				[titles.put, titles.get, titles.remove],
				ReportFormat( ", ", 0, 0, 0, 2 )
			),
			ChartDescription (
				titles.treeMapRatios, titles.categoryTitle, titles.valTitle,
				[titles.put, titles.get, titles.remove],
				ReportFormat( ", ", 0, 0, 0, 2 )
			)
		],
		reporter
	);
	context.proceed();
}

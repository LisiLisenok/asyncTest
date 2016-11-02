import herd.asynctest {

	AsyncTestContext,
	parameterized,
	AsyncPrePostContext,
	arguments
}
import ceylon.test {

	test,
	afterTestRun
}
import ceylon.collection {

	HashMap,
	TreeMap
}
import java.util {

	JHashMap=HashMap,
	JTreeMap=TreeMap
}
import herd.asynctest.chart {

	ReportFormat,
	ConsoleReporter,
	Reporter,
	CSVReporter,
	CombinedReporter,
	ChartBuilder,
	Plotter
}
import herd.asynctest.match {

	LessOrEqual
}
import herd.asynctest.rule {

	StatisticRule,
	testRule,
	Verifier
}


"Test parameters: 
 * total items test map has to contain
 * number of test repeats (test is repeated several times and reported values are mean values)
 * percent of total items to calculate number of items in get / remove tests
 "
{[[], [Integer, Integer, Float]]*} mapTestParams
		=> {
				[[], [10000, 5, 0.3]],
				[[], [50000, 5, 0.3]],
				[[], [100000, 5, 0.3]],
				[[], [150000, 5, 0.3]],
				[[], [200000, 5, 0.3]]
		};

"Tolearance to compare Ceylon to Java
 (if actual ratio exceeded `1 + tolerance` test is considered as failured otherwise it is successfull)."
[Float] comparisonTolerance => [0.25];


arguments( `value comparisonTolerance` )
class CeylonJavaMapMicrobenchmark( Float tolerance )
{
	
	"Reporter used to report plots"
	Reporter plotReporter = 
		CombinedReporter {
			ConsoleReporter (
				ReportFormat( ", ", 0, 0, 0, 0 )
			),
			CSVReporter (
				ReportFormat( ", ", 0, 0, 0, 0 ),
				"../report.csv",
				true
			)
		};
	
	// Charts and plotters to plot test results
	ChartBuilder putChart = ChartBuilder( titles.put, titles.categoryTitle, titles.valTitle );
	Plotter ceylonHashPutPlotter = putChart.addPlot( titles.ceylonHashMap );
	Plotter ceylonTreePutPlotter = putChart.addPlot( titles.ceylonTreeMap );
	Plotter javaHashPutPlotter = putChart.addPlot( titles.javaHashMap );
	Plotter javaTreePutPlotter = putChart.addPlot( titles.javaTreeMap );
	
	ChartBuilder getChart = ChartBuilder( titles.get, titles.categoryTitle, titles.valTitle );
	Plotter ceylonHashGetPlotter = getChart.addPlot( titles.ceylonHashMap );
	Plotter ceylonTreeGetPlotter = getChart.addPlot( titles.ceylonTreeMap );
	Plotter javaHashGetPlotter = getChart.addPlot( titles.javaHashMap );
	Plotter javaTreeGetPlotter = getChart.addPlot( titles.javaTreeMap );
	
	ChartBuilder removeChart = ChartBuilder( titles.remove, titles.categoryTitle, titles.valTitle );
	Plotter ceylonHashRemovePlotter = removeChart.addPlot( titles.ceylonHashMap );
	Plotter ceylonTreeRemovePlotter = removeChart.addPlot( titles.ceylonTreeMap );
	Plotter javaHashRemovePlotter = removeChart.addPlot( titles.javaHashMap );
	Plotter javaTreeRemovePlotter = removeChart.addPlot( titles.javaTreeMap );
	
	ChartBuilder hashMapRatioChart = ChartBuilder (
		titles.hashMapRatios, titles.categoryTitle, titles.valRatioTitle,
		ReportFormat( ", ", 0, 0, 2, 2 )
	);
	Plotter putHashRatioPlotter = hashMapRatioChart.addPlot( titles.put );
	Plotter getHashRatioPlooter = hashMapRatioChart.addPlot( titles.get );
	Plotter removeHashRatioPlooter = hashMapRatioChart.addPlot( titles.remove );
	
	ChartBuilder treeMapRatioChart = ChartBuilder (
		titles.treeMapRatios, titles.categoryTitle, titles.valRatioTitle,
		ReportFormat( ", ", 0, 0, 2, 2 )
	);
	Plotter putTreeRatioPlotter = treeMapRatioChart.addPlot( titles.put );
	Plotter getTreeRatioPlooter = treeMapRatioChart.addPlot( titles.get );
	Plotter removeTreeRatioPlooter = treeMapRatioChart.addPlot( titles.remove );


	// store statistic data for each test
	shared testRule StatisticRule putCeylon = StatisticRule();
	shared testRule StatisticRule putJava = StatisticRule();
	shared testRule StatisticRule getCeylon = StatisticRule();
	shared testRule StatisticRule getJava = StatisticRule();
	shared testRule StatisticRule removeCeylon = StatisticRule();
	shared testRule StatisticRule removeJava = StatisticRule();

	// verify test success with given tolerance
	shared testRule Verifier<Float> verifyPut = Verifier<Float>(
		() => putCeylon.statisticSummary.mean / putJava.statisticSummary.mean,
		LessOrEqual( 1.0 + tolerance ), "'put' Ceylon / Java ratio", true
	);
	shared testRule Verifier<Float> verifyGet = Verifier<Float>(
		() => getCeylon.statisticSummary.mean / getJava.statisticSummary.mean,
		LessOrEqual( 1.0 + tolerance ), "'get' Ceylon / Java ratio", true
	);
	shared testRule Verifier<Float> verifyRemove = Verifier<Float>(
		() => removeCeylon.statisticSummary.mean / removeJava.statisticSummary.mean,
		LessOrEqual( 1.0 + tolerance ), "'remove' Ceylon / Java ratio", true
	);
	

	afterTestRun
	shared void dispose( AsyncPrePostContext context ) {
		plotReporter.report (
			putChart.build(), getChart.build(), removeChart.build(),
			hashMapRatioChart.build(), treeMapRatioChart.build()
		);
		context.proceed();
	}
	

	"Runs `HashMap` test. Compares performance Ceylon `HashMap` to Java one.  
	 Test is performed using `chartMapTest`.  
	 Results are reported using `plotTestResult`."
	test parameterized( `value mapTestParams` )
	shared void hashMap (
		"Context the test is performed on." AsyncTestContext context,
		"Total number of items to be put in tested map." Integer totalItems,
		"Number of test repeats." Integer repeats,
		"Percent of total items to calculate number of items in get / remove tests." Float removePercent
	) {
		// Ceylon HashMap
		chartMapTest (
			context, totalItems, repeats, removePercent,
			CeylonMapWrapper( HashMap<String, Integer>() ),
			ceylonHashPutPlotter, ceylonHashGetPlotter, ceylonHashRemovePlotter,
			putCeylon, getCeylon, removeCeylon
		);
	
		// Java HashMap
		chartMapTest (
			context, totalItems, repeats, removePercent,
			JavaMapWrapper( JHashMap<String, Integer>() ),
			javaHashPutPlotter, javaHashGetPlotter, javaHashRemovePlotter,
			putJava, getJava, removeJava
		);
	
		plotTestResult (
			totalItems, putHashRatioPlotter, getHashRatioPlooter, removeHashRatioPlooter
		);
		context.complete ();
	}


	"Runs `TreeMap` test. Compares performance Ceylon `TreeMap` to Java one.  
	 Test is performed using `chartMapTest`.  
	 Results are reported using `plotTestResult`."
	test parameterized( `value mapTestParams` )
	shared void treeMap (
		"Context the test is performed on." AsyncTestContext context,
		"Total number of items to be put in tested map." Integer totalItems,
		"Number of test repeats." Integer repeats,
		"Percent of [[totalItems]] used in get / remove tests." Float removePercent
	) {
		// Ceylon TreeMap
		chartMapTest (
			context, totalItems, repeats, removePercent,
			CeylonMapWrapper( TreeMap<String, Integer>( increasing<String> ) ),
			ceylonTreePutPlotter, ceylonTreeGetPlotter, ceylonTreeRemovePlotter,
			putCeylon, getCeylon, removeCeylon
		);

		// Java TreeMap
		chartMapTest (
			context, totalItems, repeats, removePercent,
			JavaMapWrapper( JTreeMap<String, Integer>( stringComparator ) ),
			javaTreePutPlotter, javaTreeGetPlotter, javaTreeRemovePlotter,
			putJava, getJava, removeJava
		);
	
		plotTestResult (
			totalItems, putTreeRatioPlotter, getTreeRatioPlooter, removeTreeRatioPlooter
		);
		context.complete ();
	}
	
	
	"Runs map test and stores results in corresponding charts.
	 The test is repeated [[repeats]] times and reported values are averaged by the number of repeats.  
	 After each repeat initial map is cleared and reused.
	 "
	void chartMapTest (
		"Context the test is run on." AsyncTestContext context,
		"Total items in the map." Integer totalItems,
		"Total number of test repeats." Integer repeats,
		"Percent from total items -> items used in get / remove tests." Float removePercent,
		"Map the test is performed on." MapWrapper<String, Integer> map,
		Plotter putPlotter, Plotter getPlotter, Plotter removePlotter,
		StatisticRule putRule, StatisticRule getRule, StatisticRule removeRule
	) {
		
		"total number of items to be > 0"
		assert( totalItems > 0 );
		"attempts to be > 0"
		assert( repeats > 0 );
		
		// test map
			
		variable Integer count = 0;
		variable Integer start = 0;
		String prefix = "value";
			
		// warming up
		for ( upper in 0 : 100 ) {
			for ( lower in 0 : 10000 ) {}
		}
			
		while ( count < repeats ) {
			map.clear();
			
			// test put
			start = system.nanoseconds;
			variable Integer putCount = 0; 
			while ( putCount < totalItems ) {
				map.put( prefix + putCount.string, putCount );
				putCount ++;
			}
			putRule.sample( ( system.nanoseconds - start ) / 1000000.0 );
			
			// test get
			value indexies = keyList( prefix, totalItems, removePercent );
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.get( item );
			}
			getRule.sample( ( system.nanoseconds - start ) / 1000000.0 );
			
			// test remove
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.remove( item );
			}
			removeRule.sample( ( system.nanoseconds - start ) / 1000000.0 );
			
			count ++;
		}
		
		// store tested data
		putPlotter.addPoint( totalItems.float, putRule.statisticSummary.mean );
		getPlotter.addPoint( totalItems.float, getRule.statisticSummary.mean );
		removePlotter.addPoint( totalItems.float, removeRule.statisticSummary.mean );
	}
	
	
	"Fills results of testing to plotters. Results are within StatisticRule's."
	void plotTestResult (
		"Total number of items in the map." Integer totalItems,
		Plotter putPlotter, Plotter getPlotter, Plotter removePlotter
	) {
		
		Float items = totalItems.float;
		putPlotter.addPoint( items, putCeylon.statisticSummary.mean / putJava.statisticSummary.mean );
		getPlotter.addPoint( items, getCeylon.statisticSummary.mean / getJava.statisticSummary.mean );
		removePlotter.addPoint( items, removeCeylon.statisticSummary.mean / removeJava.statisticSummary.mean );
	}
	
}

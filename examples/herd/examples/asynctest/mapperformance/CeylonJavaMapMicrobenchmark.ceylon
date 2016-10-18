import herd.asynctest {

	AsyncTestContext,
	TestSuite,
	TestInitContext,
	sequential
}
import ceylon.test {

	parameters,
	test
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


"Test parameters: 
 * total items test map has to contain
 * number of test repeats (test is repeated several times and reported values are mean values)
 * percent of total items to calculate number of items in get / remove tests
 * tolearance to compare Ceylon to Java
   (if actual ratio exceeded `1 + tolerance` test is considered as failured otherwise it is successfull)
 "
{[Integer, Integer, Float, Float]*} mapTestParams
		=> {
			[10000, 5, 0.3, 0.25],
			[50000, 5, 0.3, 0.25],
			[100000, 5, 0.3, 0.25],
			[150000, 5, 0.3, 0.25],
			[200000, 5, 0.3, 0.25]
		};


sequential class CeylonJavaMapMicrobenchmark() satisfies TestSuite
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

	
	shared actual void dispose() {
		plotReporter.report (
			putChart.build(), getChart.build(), removeChart.build(),
			hashMapRatioChart.build(), treeMapRatioChart.build()
		);
	}
	
	shared actual void initialize( TestInitContext initContext ) => initContext.proceed();
	

	"Runs HashMap test. Compares Ceylon map to Java one.  
	 Test is performed using `chartMapTest`.  
	 Results are reported using `fillTestResult`."
	test
	parameters( `value mapTestParams` )
	shared void hashMap (
		"Context the test is performed on." AsyncTestContext context,
		"Total number of items to be put in tested map." Integer totalItems,
		"Number of test repeats." Integer repeats,
		"Percent of total items to calculate number of items in get / remove tests." Float removePercent,
		"Tolerance to compare Ceylon to Java." Float tolerance
	) {
		context.start();
	
		// Ceylon HashMap
		value ceylonResult = chartMapTest (
			context, totalItems, repeats, removePercent,
			CeylonMapWrapper( HashMap<String, Integer>() ),
			ceylonHashPutPlotter, ceylonHashGetPlotter, ceylonHashRemovePlotter
		);
	
		// Java HashMap
		value javaResult = chartMapTest (
			context, totalItems, repeats, removePercent,
			JavaMapWrapper( JHashMap<String, Integer>() ),
			javaHashPutPlotter, javaHashGetPlotter, javaHashRemovePlotter
		);
	
		context.complete (
			fillTestResult (
				context, ceylonResult, javaResult, tolerance, totalItems,
				putHashRatioPlotter, getHashRatioPlooter, removeHashRatioPlooter
			)
		);
	}


	"Runs TreeMap test. Compares Ceylon map to Java one.  
	 Test is performed using `chartMapTest`.  
	 Results are reported using `fillTestResult`."
	test
	parameters( `value mapTestParams` )
	shared void treeMap (
		"Context the test is performed on." AsyncTestContext context,
		"Total number of items to be put in tested map." Integer totalItems,
		"Number of test repeats." Integer repeats,
		"Percent of [[totalItems]] used in get / remove tests." Float removePercent,
		"Tolerance to compare Ceylon to Java." Float tolerance
	) {
		context.start();
	
		// Ceylon TreeMap
		value ceylonResult = chartMapTest (
			context, totalItems, repeats, removePercent,
			CeylonMapWrapper( TreeMap<String, Integer>( increasing<String> ) ),
			ceylonTreePutPlotter, ceylonTreeGetPlotter, ceylonTreeRemovePlotter
		);

		// Java TreeMap
		value javaResult = chartMapTest (
			context, totalItems, repeats, removePercent,
			JavaMapWrapper( JTreeMap<String, Integer>( stringComparator ) ),
			javaTreePutPlotter, javaTreeGetPlotter, javaTreeRemovePlotter
		);
	
		context.complete (
			fillTestResult (
				context, ceylonResult, javaResult, tolerance, totalItems,
				putTreeRatioPlotter, getTreeRatioPlooter, removeTreeRatioPlooter
			)
		);
	}
	
	
	"Runs map test and stores results in corresponding charts.
	 The test is repeated [[repeats]] times and reported values are averaged by the number of repeats.  
	 After each repeat initial map is cleared and reused.
	 "
	Float[3] | Throwable chartMapTest (
		"Context the test is run on." AsyncTestContext context,
		"Total items in the map." Integer totalItems,
		"Total number of test repeats." Integer repeats,
		"Percent from total items -> items used in get / remove tests." Float removePercent,
		"Map test is performed on." MapWrapper<String, Integer> map,
		Plotter putPlotter, Plotter getPlotter, Plotter removePlotter
	) {
		
		"total number of items to be > 0"
		assert( totalItems > 0 );
		"attempts to be > 0"
		assert( repeats > 0 );
		
		// test map
			
		variable Integer count = -1;
		variable Float sumPut = 0.0;
		variable Float sumGet = 0.0;
		variable Float sumRemove = 0.0;
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
			if ( count > -1 ) { sumPut += ( system.nanoseconds - start ) / 1000000.0; }
				
			// test get
			value indexies = keyList( prefix, totalItems, removePercent );
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.get( item );
			}
			if ( count > -1 ) { sumGet += ( system.nanoseconds - start ) / 1000000.0; }
				
			// test remove
			start = system.nanoseconds;
			for ( item in indexies ) {
				map.remove( item );
			}
			if ( count > -1 ) { sumRemove += ( system.nanoseconds - start ) / 1000000.0; }
			
			count ++;
		}
		
		// mean times
		sumPut = sumPut / repeats;
		sumGet = sumGet / repeats;
		sumRemove = sumRemove / repeats;
		
		// store tested data
		putPlotter.addPoint( totalItems.float, sumPut );
		getPlotter.addPoint( totalItems.float, sumGet );
		removePlotter.addPoint( totalItems.float, sumRemove );
		
		return [sumPut, sumGet, sumRemove];
	}
	
	
	"Fills results of testing to context.  
	 Returns `String` to complete test with."
	String fillTestResult (
		"Context results to be filled in." AsyncTestContext context,
		"Results of Ceylon test." Float[3] | Throwable ceylonResult,
		"Results of Java test." Float[3] | Throwable javaResult,
		"Tolerance to compare Ceylon to Java." Float tolerance,
		"Total number of items in the map." Integer totalItems,
		Plotter putPlotter, Plotter getPlotter, Plotter removePlotter
	) {
		
		if ( is Throwable ceylonResult ) {
			context.abort( ceylonResult );
			return "";
		}
		else if ( is Throwable javaResult ) {
			context.abort( javaResult );
			return "";
		}
		else {
			// Ceylon / Java ratios
			Float putRatio = ceylonResult[0] / javaResult[0];
			Float getRatio = ceylonResult[1] / javaResult[1];
			Float removeRatio = ceylonResult[2] / javaResult[2];
			
			// Formated string representation of ratios
			String putRatioStr = formatFloat( putRatio, 2, 2 );
			String getRatioStr = formatFloat( getRatio, 2, 2 );
			String removeRatioStr = formatFloat( removeRatio, 2, 2 );

			context.assertThat( putRatio, LessOrEqual( 1.0 + tolerance ), "'put' Ceylon / Java ratio", true );
			context.assertThat( getRatio, LessOrEqual( 1.0 + tolerance ), "'get' Ceylon / Java ratio", true );
			context.assertThat( removeRatio, LessOrEqual( 1.0 + tolerance ), "'remove' Ceylon / Java ratio", true );
			
			putPlotter.addPoint( totalItems.float, putRatio );
			getPlotter.addPoint( totalItems.float, getRatio );
			removePlotter.addPoint( totalItems.float, removeRatio );
			
			// completing the test, argument will be used only if test is succeeded
			return "all 'put' of ``putRatioStr``, 'get' of ``getRatioStr`` and 'remove' of ``removeRatioStr`` "
					+ "Ceylon / Java ratios are less then target ``1 + tolerance``";
		}
	}
	
}

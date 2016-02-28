import herd.asynctest {

	AsyncTestContext,
	AsyncTestExecutor,
	init
}
import ceylon.test {

	parameters,
	test,
	testExecutor
}
import ceylon.collection {

	HashMap,
	TreeMap
}
import java.util {

	JHashMap=HashMap,
	JTreeMap=TreeMap
}


"Test parameters: 
 * total items test map has to contain
 * number of test repeats
 * percent of total items to calculate number of items in get / remove tests
 * target ratio Ceylon to Java
 "
{[Integer, Integer, Float, Float]*} mapTestParams
		=> {
			[10000, 100, 0.3, 1.25],
			[50000, 100, 0.3, 1.25],
			[100000, 100, 0.3, 1.25],
			[150000, 100, 0.3, 1.25],
			[200000, 100, 0.3, 1.25]
		};


"Runs HashMap test. Compares Ceylon map to Java one.  
 Test is performed using `chartMapTest`.  
 Results are reported using `fillTestResult`."
test
testExecutor( `class AsyncTestExecutor` )
init( `function plotInitialization` )
parameters( `value mapTestParams` )
shared void runHashMapTest (
	"Context the test is performed on." AsyncTestContext context,
	"Total number of items to be put in tested map." Integer totalItems,
	"Number of test repeats." Integer repeats,
	"Percent of total items to calculate number of items in get / remove tests." Float removePercent,
	"Target ratio Ceylon to Java." Float targetRatio
) {
	context.start();
	
	// Ceylon HashMap
	value ceylonResult = chartMapTest (
		context, totalItems, repeats, removePercent, titles.ceylonHashMap, CeylonMapWrapper( HashMap<String, Integer>() )
	);
	
	// Java HashMap
	value javaResult = chartMapTest (
		context, totalItems, repeats, removePercent, titles.javaHashMap, JavaMapWrapper( JHashMap<String, Integer>() )
	);
	
	context.complete( fillTestResult( context, ceylonResult, javaResult, targetRatio, totalItems, titles.hashMapRatios ) );
}


"Runs TreeMap test. Compares Ceylon map to Java one.  
 Test is performed using `chartMapTest`.  
 Results are reported using `fillTestResult`."
test
testExecutor( `class AsyncTestExecutor` )
init( `function plotInitialization` )
parameters( `value mapTestParams` )
shared void runTreeMapTest (
	"Context the test is performed on." AsyncTestContext context,
	"Total number of items to be put in tested map." Integer totalItems,
	"Number of test repeats." Integer repeats,
	"Percent of [[totalItems]] used in get / remove tests." Float removePercent,
	"Target ratio Ceylon to Java." Float targetRatio
) {
	context.start();
	
	// Ceylon TreeMap
	value ceylonResult = chartMapTest (
		context, totalItems, repeats, removePercent, titles.ceylonTreeMap,
		CeylonMapWrapper( TreeMap<String, Integer>( increasing<String> ) )
	);

	// Java TreeMap
	value javaResult = chartMapTest (
		context, totalItems, repeats, removePercent, titles.javaTreeMap,
		JavaMapWrapper( JTreeMap<String, Integer>( stringComparator ) )
	);
	
	context.complete( fillTestResult( context, ceylonResult, javaResult, targetRatio, totalItems, titles.treeMapRatios ) );
}

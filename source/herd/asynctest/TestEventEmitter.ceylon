import ceylon.test.engine.spi {

	TestExecutionContext
}
import ceylon.test {

	TestResult,
	TestState,
	TestDescription
}



"Emits test events."
by( "Lis" )
interface TestEventEmitter {
	
	"Fills results of the test to execution context. Here in order to avoind race conditions when filling to test runner."
	shared default void fillTestResults (
		"Context to be filled with results." TestExecutionContext context,
		"Test results." TestOutput[] testOutputs,
		"Total test elapsed time." Integer runInterval,
		"Total number of performed executions." Integer executions
	) {
		startEvent( context );
		TestDescription runDescription = context.description;
		if ( nonempty testOutputs ) {
			variable Integer index = 0;
			for ( res in testOutputs ) {
				variantResultEvent( context, res, ++ index );
			}
			variable TestState state = testOutputs.first.state;
			for ( item in testOutputs.rest ) {
				if ( item.state > state ) { state = item.state; }
			}
			finishEvent (
				context,
				TestResult( runDescription, state, true, null, runInterval ),
				executions
			);
		}
		else {
			finishEvent (
				context,
				TestResult( runDescription, TestState.success, true, null, runInterval ),
				executions
			);
		}
	}
	
	"Raises test start event."
	shared formal void startEvent( "Context to raise event on." TestExecutionContext context );
	
	"Raises test variant results event."
	shared formal void variantResultEvent (
		"Context to raise event on." TestExecutionContext context,
		"Test output to be passed as variant result." TestOutput testOutput,
		"Variant index." Integer index
	);
	
	"Raises test finish event."
	shared formal void finishEvent (
		"Context to raise event on." TestExecutionContext context,
		"Results of the test." TestResult testResult,
		"Total number of performed executions." Integer executions
	);
	
}

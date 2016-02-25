import ceylon.test {

	parameters,
	test,
	testExecutor
}
import herd.asynctest {

	AsyncTestContext,
	AsyncTestExecutor
}


"Fibonnachi test parameters."
see( `function runFibonnachiTest` )
{[Integer, Integer]*} fibonnachiNumbers =>
		{
			[3, 2], [4, 3], [5, 5], [6, 8], [7, 13], [8, 21], [9, 34], [10, 55]
		};


"Runs test of Fibonnachi numbers calculations.  
 Testing:
 * comparison of expected value to calculated one
 * comparison of calculated index of Fibonnachi number with passed one - this will fail if pass index `2`
 
 The function is marked with `testExecutor` annotation in order to perform asynchronous test.
 Alternatively `testExecutor` annotation can be used at module level."
test parameters( `value fibonnachiNumbers` )
testExecutor( `class AsyncTestExecutor` )
shared void runFibonnachiTest (
	"Context to send test results." AsyncTestContext context,
	"Index of fibonnachi number to be calculated." Integer indexOfFibonnachiNumber,
	"Expected results of the calculations." Integer expectedFibonnachiNumber
) {
	// starts testing on context
	context.start();
	
	// do testing procedure
	asyncPositiveFibonnachiNumber( indexOfFibonnachiNumber ).completed (
		( Integer calculatedFibonnachiNumber ) {
			// compare calculated and expected values and notify context if fails
			// Don't use `ceylon.test.assert...` here. It will throw on separated thread and will cause abnormal program termination
			context.assertTrue (
				calculatedFibonnachiNumber == expectedFibonnachiNumber,
				"calculated Fibonnachi number ``calculatedFibonnachiNumber`` is not equal to expected one ``expectedFibonnachiNumber``",
				"number equality"
			);
			
			// calculates index from resulting Fibonnachi number and compare it with passed one
			try {
				value index = fibonnachiNumberIndex( calculatedFibonnachiNumber );
				context.assertTrue (
					index == indexOfFibonnachiNumber,
					"calculated index of Fibonnachi number ``index`` is not equal to expected one ``indexOfFibonnachiNumber``",
					"index equality"
				);
			}
			catch ( Throwable err ) {
				context.fail( err );
			}
			
			// completes the test when results reported
			context.complete( "Fibonnachi number is ``calculatedFibonnachiNumber``" );
		},
		( Throwable reason ) {
			// fail the test with error
			// Don't use `ceylon.test.fail` here. It will throw on separated thread and will cause abnormal program termination
			context.fail( reason );
			// completes the test when fail reported
			context.complete();
		}
	);
	
	// just return whithout completion - the test will be completed later when promise is resolved
}

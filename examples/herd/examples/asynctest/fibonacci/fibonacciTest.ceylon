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
see( `function runFibonacciTest` )
{[Integer, Integer]*} fibonacciNumbers =>
		{
			[3, 2], [4, 3], [5, 5], [6, 8], [7, 13], [8, 21], [9, 34], [10, 55]
		};


"Runs test of Fibonacci numbers calculations.  
 Testing:
 * comparison of expected value to calculated one
 * comparison of calculated index of Fibonacci number with passed one - this will fail if pass index `2`
 
 The function is marked with `testExecutor` annotation in order to perform asynchronous test.
 Alternatively `testExecutor` annotation can be used at module level."
test parameters( `value fibonacciNumbers` )
testExecutor( `class AsyncTestExecutor` )
shared void runFibonacciTest (
	"Context to send test results." AsyncTestContext context,
	"Index of fibonnachi number to be calculated." Integer indexOfFibonacciNumber,
	"Expected results of the calculations." Integer expectedFibonacciNumber
) {
	// starts testing on context
	context.start();
	
	// do testing procedure
	asyncPositiveFibonacciNumber( indexOfFibonacciNumber ).completed (
		( Integer calculatedFibonacciNumber ) {
			// compare calculated and expected values and notify context if fails
			// Don't use `ceylon.test.assert...` here. It will throw on separated thread and will cause abnormal program termination
			context.assertTrue (
				calculatedFibonacciNumber == expectedFibonacciNumber,
				"calculated Fibonacci number ``calculatedFibonacciNumber`` is not equal to expected one ``expectedFibonacciNumber``",
				"number equality"
			);
			
			// calculates index from resulting Fibonacci number and compare it with passed one
			try {
				value index = fibonacciNumberIndex( calculatedFibonacciNumber );
				context.assertTrue (
					index == indexOfFibonacciNumber,
					"calculated index of Fibonacci number ``index`` is not equal to expected one ``indexOfFibonacciNumber``",
					"index equality"
				);
			}
			catch ( Throwable err ) {
				context.fail( err );
			}
			
			// completes the test when results reported
			context.complete( "Fibonacci number is ``calculatedFibonacciNumber``" );
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

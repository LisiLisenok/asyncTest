import ceylon.test {

	test,
	testExecutor
}
import herd.asynctest {

	AsyncTestContext,
	AsyncTestExecutor,
	parameterized
}
import herd.asynctest.match {

	EqualTo,
	Mapping,
	MatchResult
}


"Fibonacci test parameters."
see( `function runFibonacciTest` )
{[[],[Integer, Integer]]*} fibonacciNumbers =>
		{
			[[],[3, 2]], [[],[4, 3]], [[],[5, 5]], [[],[6, 8]], [[],[7, 13]], [[],[8, 21]], [[],[9, 34]], [[],[10, 55]]
		};


"Runs test of Fibonacci numbers calculations.  
 Testing:
 * comparison of expected value to calculated one
 * comparison of calculated index of Fibonacci number with passed one - this will fail if pass index of `2`
 
 The function is marked with `testExecutor` annotation in order to perform asynchronous test.
 Alternatively `testExecutor` annotation can be used at module level."
test parameterized( `value fibonacciNumbers` )
testExecutor( `class AsyncTestExecutor` )
shared void runFibonacciTest (
	"Context to send test results." AsyncTestContext context,
	"Index of Fibonacci number to be calculated." Integer indexOfFibonacciNumber,
	"Expected results of the calculations." Integer expectedFibonacciNumber
) {
	// perform calculation and checking
	context.assertThat<Integer> (
		asyncPositiveFibonacciNumber( indexOfFibonacciNumber ),
		EqualTo( expectedFibonacciNumber ).and( Mapping( fibonacciNumberIndex, EqualTo( indexOfFibonacciNumber ) ) ),
		"",
		true
	).onComplete( ( MatchResult|Throwable res ) => context.complete() );
	
	// just return whithout completion
	// the test will be completed later when promise returned by `asyncPositiveFibonacciNumber` is resolved
}

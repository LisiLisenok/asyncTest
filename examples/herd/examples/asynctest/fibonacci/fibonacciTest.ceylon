import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext,
	parameterized,
	async,
	FunctionParameters
}
import herd.asynctest.match {

	EqualTo,
	Mapping,
	MatchResult
}


"Fibonacci test parameters."
see( `function runFibonacciTest` )
{FunctionParameters*} fibonacciNumbers => {
		FunctionParameters([],[3, 2]),
		FunctionParameters([],[4, 3]),
		FunctionParameters([],[5, 5]),
		FunctionParameters([],[6, 8]),
		FunctionParameters([],[7, 13]),
		FunctionParameters([],[8, 21]),
		FunctionParameters([],[9, 34]),
		FunctionParameters([],[10, 55])
	};


"Runs test of Fibonacci numbers calculations.  
 Testing:
 * comparison of expected value to calculated one
 * comparison of calculated index of Fibonacci number with passed one - this will fail if pass index of `2`
 
 The function is marked with `testExecutor` annotation in order to perform asynchronous test.
 Alternatively `testExecutor` annotation can be used at module level."
test async parameterized( `value fibonacciNumbers` )
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

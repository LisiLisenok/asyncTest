import herd.asynctest {
	AsyncMessageContext,
	TestInfo
}


"Test runner is applied to execute test function with a one test variant.  
 
 > Just test function is executed by runner. All `before`, `after` and `testRule` (including `TestStatement`)
   callbacks are executed outside the runner!  
 "
since( "0.6.0" ) by( "Lis" )
shared interface AsyncTestRunner {
	
	"Runs test function `testing` on a given test context.  
	 `testing` function is not as that is applied from [[TestInfo.testFunction]]!
	 It is **not** recommended to apply test function declaration to call test function
	 rather than to put direct call of the given `testing` function.  
	 
	 Callbacks from `testing` to the `context` are synchronized - only one `context` method is
	 executed at a given time.  
	 But if test functions are executed in concurrent mode
	 (see, [[module herd.asynctest#suites]] and [[herd.asynctest::concurrent]])
	 and the same runner _value_ is submited to a number of test functions race condition still may occur since 
	 the runner is executed with different contexts.  
	 Two solutions may be recommended in this case:  
	 * Using factory function to instantiate different runners for different test functions call.  
	 * Organizing runner to be free of such race conditions.  
	 "
	shared formal void run (
		"Context to run the test function with."
		AsyncMessageContext context,
		"Test function to be run."
		void testing( AsyncMessageContext context ),
		"Information on the currently run test variant."
		TestInfo info
	);
	
}

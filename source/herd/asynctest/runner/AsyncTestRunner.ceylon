


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
	 
	 At the same time runner may be executed by above runner which may call simultaneously
	 the `run` method from several threads. Each runner is responsible for the thread safe execution.   
	 "
	shared formal void run (
		"Context to run the test function with."
		AsyncRunnerContext context,
		"Test function to be run."
		void testing( AsyncRunnerContext context ),
		"Information on the currently run test variant."
		TestInfo info
	);
	
}

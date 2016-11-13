import herd.asynctest {
	AsyncTestContext,
	TestInfo
}


"Interface each test runner has to satisfy."
since( "0.6.0" ) by( "Lis" )
shared interface AsyncTestRunner {
	
	"Runs test function `testing` on a given test context.  
	 `testing` function is not as that is applied from [[TestInfo.testFunction]]!
	 It is **not** recommended to apply test function declaration to call test function
	 rather than to put direct call of the given `testing` function."
	shared formal void run (
		"Test function to be run."
		void testing( AsyncTestContext context ),
		"Context to run the test function with."
		AsyncTestContext context,
		"Information on the currently run test variant."
		TestInfo info
	);
	
}

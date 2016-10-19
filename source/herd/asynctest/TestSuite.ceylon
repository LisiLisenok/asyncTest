
"Test suite can be used in order to organize test functions into a one suite and to perform common
 test initialization / disposing.    
 
 Before executing any test [[TestSuite.initialize]] is called by test executor
 with initializer context of [[TestInitContext]].  
 Initializer has to call [[TestInitContext.proceed]] or [[TestInitContext.abort]] when initialization
 is completed or failured, correspondently.  
 
 When test is completed [[TestSuite.dispose]] is called by test executor.
 The method takes [[AsyncTestContext]] and general test procedure has to be applied withing dispose method:
 * call [[AsyncTestContext.start]] before start disposing
 * perform disposing and report failures or successes via [[AsyncTestContext]] if needed
 * call [[AsyncTestContext.complete]] to complete the disposing	 
 
 
 >SDK `ceylon.test::after` and `ceylon.test::before` annotations don't work with [[AsyncTestExecutor]].  
 
 
 --------------------------------------------
 "
see( `interface TestInitContext` )
by( "Lis" )
shared interface TestSuite {
	
	"Initializes test suite. Called before test suite executed.  
	 Initialization can be asynchronous.  
	 When initialization is completed or failed call [[TestInitContext.proceed]] or [[TestInitContext.abort]],
	 correspondently. Test executor will block test thread until the functions called."
	shared formal void initialize( TestInitContext initContext );
	
	"Disposes the suite. Called after test suite executed.  
	 Takes [[AsyncTestContext]] which may be used to report errors or successes occurred during test disposing.
	 General test procedure has to be applied withing dispose method:
	 * call [[AsyncTestContext.start]] before start disposing
	 * perform disposing and report failures or successes via [[AsyncTestContext]] if needed
	 * call [[AsyncTestContext.complete]] to complete the disposing	 
	 "
	shared formal void dispose (
		"Disposing context. May be used to report errors or successes occurred during test disposing."
		AsyncTestContext context
	);
	
}

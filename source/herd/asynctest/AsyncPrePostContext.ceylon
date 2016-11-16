import herd.asynctest.rule {

	SuiteRule,
	TestRule
}


"Allows prepost function functions to interract with test executor.  
 
 Prepost function has to call [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]]
 when initialization or disposing is completed or errored, correspondently.  
 The test executor blocks execution thread until [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]] is called.
 
 See details about test initialization / disposing in [[module herd.asynctest]].
 "
see( `interface TestRule`, `interface SuiteRule` )
since( "0.6.0" ) by( "Lis" )
shared interface AsyncPrePostContext {
	"Initialization or disposing has been completed - proceed with the test."
	shared formal void proceed();
	
	"Aborts the test initialization or disposing."
	shared formal void abort( Throwable reason, String title = "" );
	
	"Information about the current test:
	 * Suite prepost functions are provided with info about themselves.  
	 * Test prepost functions are provided with test function info.  
	 "
	shared formal TestInfo testInfo;
}

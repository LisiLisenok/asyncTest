

"Allows initializer function to interract with test executor.  
 
 Initializer has to call [[TestInitContext.proceed]] or [[TestInitContext.abort]] when initialization is completed or errored
 since executor blocks execution thread until [[TestInitContext.proceed]] or [[TestInitContext.abort]] is called.
 
 --------------------------------------------
 "
see( `interface AsyncTestContext`, `interface TestSuite` )
since( "0.5.0" )
by( "Lis" )
shared interface TestInitContext {
	
	"Proceeds the test."
	shared formal void proceed();
	
	"Aborts the test proceeding."
	shared formal void abort( Throwable reason, String title = "" );
	
}

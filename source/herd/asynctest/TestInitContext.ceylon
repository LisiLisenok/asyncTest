

"Allows initializer function to interract with test executor.  
 
 Initializer has to call [[AsyncInitContext.proceed]] or [[AsyncInitContext.abort]] when initialization is completed or errored
 since executor blocks execution thread until [[AsyncInitContext.proceed]] or [[AsyncInitContext.abort]] is called.
 
 --------------------------------------------
 "
see( `interface AsyncTestContext` )
since( "0.5.0" )
by( "Lis" )
shared interface AsyncInitContext {
	
	"Proceeds the test."
	shared formal void proceed();
	
	"Aborts the test proceeding."
	shared formal void abort( Throwable reason, String title = "" );
	
}



"Allows pre- and post- test functions to interract with test executor.  
 
 Prepost function has to call [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]]
 when initialization or disposing is completed or errored, correspondently.  
 The test xecutor blocks execution thread until [[AsyncPrePostContext.proceed]] or [[AsyncPrePostContext.abort]] is called.
 
 See details about test initialization / disposing in [[module herd.asynctest]].
 "
see( `interface AsyncTestContext` )
since( "0.6.0" ) by( "Lis" )
shared interface AsyncPrePostContext {
	
	"Initialization or disposing has been completed - proceed with the test."
	shared formal void proceed();
	
	"Aborts the test initialization or disposing."
	shared formal void abort( Throwable reason, String title = "" );
	
}



"Interface implementation of test suite has to satisfy.  
 
 Test suite can be used in order to organize test functions into a one suite and to perform common
 test initialization / disposing.    
 Before executing any test [[TestSuite.initialize]] is called with initializer context of [[TestInitContext]].  
 Initializer has to call [[TestInitContext.proceed]] or [[TestInitContext.abort]] when initialization
 is completed or failured, correspondently.  
 When test is completed [[TestSuite.dispose]] is called.  
 
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
	
	"Disposes the suite. Called after test suite executed."
	shared formal void dispose();
	
}

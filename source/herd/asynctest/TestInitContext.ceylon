

"Allows initializer function to interract with test executor.  
 Initializer can fill in some values using [[put]]. The values can be retrieved late from [[AsyncTestContext]].  
 Additionally callback to listen when test run is finished can be added using [[addTestRunFinishedCallback]].  
 Initializer has to call [[TestInitContext.proceed]] or [[TestInitContext.abort]] when initialization is completed or errored
 since executor blocks execution thread until [[TestInitContext.proceed]] or [[TestInitContext.abort]] is called.
 "
see( `class InitAnnotation`, `function init`, `interface AsyncTestContext` )
by( "Lis" )
shared interface TestInitContext {
	
	"Proceeds the test."
	shared formal void proceed();
	
	"Aborts the test proceeding."
	shared formal void abort( Throwable reason, String title = "" );
	
	"Stores an item on context.  
	 The item can be retrieved during test execution using [[AsyncTestContext.get]] or [[AsyncTestContext.getAll]].
	 "
	shared formal void put<Item> (
		"Name of the stored item - can be retrieved by name using [[AsyncTestContext.get]]." String name,
		"Item to be stored on context." Item item,
		"Function called when test is completed in order to dispose all related resources." Anything() dispose = noop
	);
	
	"Adds callback called when test run is finished, so when all tests are processed."
	shared formal void addTestRunFinishedCallback( Anything() callback );
	
}

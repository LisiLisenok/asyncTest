

"Represents a context pushed to test initializer.  
 Initializer can fill in some values, which can be retrieved late from [[AsyncTestContext]].
 "
see( `class InitAnnotation`, `function init`, `interface AsyncTestContext` )
by( "Lis" )
shared interface TestInitContext {
	
	"Proceeds the test."
	shared formal void proceed();
	
	"Aborts the test proceeding."
	shared formal void abort( Throwable reason, String title = "" );
	
	"Stores an item on context.  
	 The item can be retrieved during test using [[AsyncTestContext.get]] or [[AsyncTestContext.getAll]].
	 "
	shared formal void put<Item> (
		"Name of the stored item - can be retrieved by name using [[AsyncTestContext.get]]." String name,
		"Item to be stored on context." Item item,
		"Function called when test is completed in order to dispose all related resources." Anything() dispose = noop
	);
	
}

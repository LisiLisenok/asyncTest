
"
 Represents object passed to test function and allows to interact with asynchronous test framework i.e. [[AsyncTestExecutor]].
 
 General test procedure within test function is:
 1. Notify test framework on test procedure starting.
 2. Perform the test itself. Notify test framework on fails.
    Several notifications are allowed. Each fail notification is represented as test variant.
 3. Notify test framework on test procedure completion, this step is nesseccary to continue testing with next execution.
 	
 	
 Example of tested function:
 	test void doTesting(AsyncTestContext context) {
 		// start testing
 		context.start();
 		
 		// perform test procedure and notify about fails, if no fails notified test is considered successfull
 		context.fail(Exception(\"exception\"), \"some exception\");
 		context.fail(AssertionError( \"assert\"), \"some assert\");
 		context.abort(Exception( \"exception\"), \"test aborted\");
 		context.assertTrue(true, \"to be \`false\`\");
 		context.assertNotNull(null, \"to be nonull\");
 		
 		// complete testing
 		context.complete(\"title which is added to test variant name only if test is succeeded\");
 	}
 	
 
 Common initialization for a set of test functions can be performed using [[init]] annotation and [[TestInitContext]].

 "
by( "Lis" )
see( `class AsyncTestExecutor` )
see( `interface TestInitContext` )
see( `function init` )
shared interface AsyncTestContext
{
	
	"Starts the testing. To be called by test function before running the test, but after initialization."
	shared formal void start();
	
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete( "Optional title which is added to test variant name only if test is succeeded" String title = "" );
	
	
	"Returns item stored on init context."
	see( `function TestInitContext.put` )
	shared formal Item? get<Item>( String name );
	
	"Returns all items of given type stored on init context."
	see( `function TestInitContext.put` )
	shared formal Item[] getAll<Item>();
	
	
	"Fails the test if the `condition` is `false`."
	shared formal void assertTrue (
		"The condition to be checked." Boolean condition,
		"Message to be put to `AssertionError`." String message,
		"Title to be shown at test name." String title = ""
	);
	
	"Fails the test if the `condition` is `true`."
	shared formal void assertFalse (
		"The condition to be checked." Boolean condition,
		"Message to be put to `AssertionError`." String message,
		"Title to be shown at test name." String title = ""
	);
	
	"Fails the test if the given `val` is not `null`."
	shared formal void assertNull (
		"The value to be checked." Anything val,
		"Message to be put to `AssertionError`." String message,
		"Title to be shown at test name." String title = ""
	);
	
	"Fails the test if the given `val` is not `null`."
	shared formal void assertNotNull (
		"The value to be checked." Anything val,
		"Message to be put to `AssertionError`." String message,
		"Title to be shown at test name." String title = ""
	);
	
	"Fails the test with either `AssertionError` or `Exception`."
	shared formal void fail (
		"Reason fails this test." Throwable reason,
		"Title to be shown at test name." String title = ""
	);
	
	"Aborts the test . Which means that some test conditions are not met"
	shared formal void abort (
		"Optional error of the aborting." Throwable? reason = null,
		"Title to be shown at test name." String title = ""
	);
	
}

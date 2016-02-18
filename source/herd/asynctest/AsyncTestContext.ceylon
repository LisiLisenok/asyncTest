
"
 Represents object passed to test function and allows to interact with asynchronous test framework i.e. [[AsyncTestExecutor]].
 
 General test procedure within test function is:
 1. Initialize.
 2. Notify test framework on test procedure starting.
 3. Perform the test itself. Notify test framework on fails.
    Several notifications are allowed. Each fail notification is represented as test variant.
 4. Dispose or cleaning.
 5. Notify test framework on test procedure completion, this step is nesseccary to continue testing with next execution.
 	
 	
 Example of tested function:
 	test void doTesting( AsyncTestContext context ) {
 		// perform initialization at first
 		init();
 		
 		// start testing
 		context.start();
 		
 		// perform test procedure and notify about fails, if no fails notified test is considered successfull
 		
 		context.fail( Exception( \"exception\" ), \"some exception\" );
 		context.fail( AssertionError( \"assert\" ), \"some assert\" );
 		context.abort( Exception( \"exception\" ), \"test aborted\" );
 		context.assertTrue( true, \"to be \`false\`\" );
 		context.assertNotNull( null, \"to be nonull\" );
 		
 		// perform disposing or cleaning here
 		dispose();
 		
 		// complete testing
 		context.complete();
 }

 "
by( "Lis" )
see( `class AsyncTestExecutor` )
shared interface AsyncTestContext
{
	
	"Starts the testing. To be called by test function before running the test, but after initialization."
	shared formal void start();
	
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete();
	
	
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

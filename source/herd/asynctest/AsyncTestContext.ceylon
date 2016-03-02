import herd.asynctest.match {

	Matcher
}

"
 Provides interaction with asynchronous test executor.
 
 General test procedure within test function is:
 
 1. Notify test executor on test procedure starting.
 2. Perform the test itself. Notify test executor on failures or successes.
    Several notifications are allowed. Each failure or success notification is represented as test variant.
 3. Notify test executor on test procedure completion (call [[AsyncTestContext.complete]]).
    This step is nesseccary to continue testing with next execution
    since test executor blocks execution thread until [[AsyncTestContext.complete]] is called.
 	
 	
 Example of tested function:
 	test testExecutor(\`class AsyncTestExecutor\`)
 	void doTesting(AsyncTestContext context) {
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
 	
 
 >Common initialization for a set of test functions can be performed using [[init]] annotation and [[TestInitContext]].
 
 
 >It is <i>not</i> required to notify with success,
  if test function doesn't notify on failure the test is considered as successfull.

 "
by( "Lis" )
see( `class AsyncTestExecutor`, `interface TestInitContext`, `function init` )
shared interface AsyncTestContext
{
	
	"Starts the testing. To be called by test function before running the test, but after initialization."
	shared formal void start();
	
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete (
		"Optional title which is added to test variant name only if test is succeeded." String title = ""
	);
	
	
	"Returns item stored on init context."
	see( `function TestInitContext.put` )
	shared formal Item? get<Item>( String name );
	
	"Returns all items of given type stored on init context."
	see( `function TestInitContext.put` )
	shared formal Item[] getAll<Item>();
	
	
	"Succeeds the test with the given `message`."
	shared formal void succeed( String message );
	
	"Fails the test if the `condition` is `false`
	 or succeeds the test if `condition` is `true` and `successMessage` is specified."
	shared formal void assertTrue (
		"The condition to be checked." Boolean condition,
		"Message to be put to `AssertionError`." String message,
		"Optional title to be shown at test name." String title = "",
		"Optional message if verification is accepted" String? successMessage = null
	);
	
	"Fails the test if the `condition` is `true`
	 or succeeds the test if `condition` is `false` and `successMessage` is specified."
	shared formal void assertFalse (
		"The condition to be checked." Boolean condition,
		"Message to be put to `AssertionError`." String message,
		"Optional title to be shown at test name." String title = "",
		"Optional message if verification is accepted" String? successMessage = null
	);
	
	"Fails the test if the given `val` is not `null`
	 or succeeds the test if val is `null` and `successMessage` is specified."
	shared formal void assertNull (
		"The value to be checked." Anything val,
		"Message to be put to `AssertionError`." String message,
		"Optional title to be shown at test name." String title = "",
		"Optional message if verification is accepted" String? successMessage = null
	);
	
	"Fails the test if the given `val` is `null`
	 or succeeds the test if val is not `null` and `successMessage` is specified."
	shared formal void assertNotNull (
		"The value to be checked." Anything val,
		"Message to be put to `AssertionError`." String message,
		"Optional title to be shown at test name." String title = "",
		"Optional message if verification is accepted" String? successMessage = null
	);
	
	
	"Fails the test if `val` doesn't match `matcher` or succeds the test otherwise."
	shared formal void assertThat<Value> (
		"Value to be matched." Value val,
		"Performs checking." Matcher<Value> matcher,
		"Optional title to be shown at test name." String title = ""
	);
	
	
	"Fails the test with either `AssertionError` or `Exception`."
	shared formal void fail (
		"Reason fails this test." Throwable reason,
		"Optional title to be shown at test name." String title = ""
	);
	
	
	"Aborts the test, which means that some test conditions are not met."
	shared formal void abort (
		"Optional error of the aborting." Throwable? reason = null,
		"Optional title to be shown at test name." String title = ""
	);
	
	"Aborts the test if `val` doesn't match `matcher` or succeds the test otherwise."
	shared formal void abortThat<Value> (
		"Value to be matched." Value val,
		"Performs checking." Matcher<Value> matcher,
		"Optional title to be shown at test name." String title = ""
	);
	
}

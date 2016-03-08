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
 		context.assertThat(true, IsFalse(), \"to be \`false\`\");
 		
 		// complete testing
 		context.complete(\"title which is added to test variant name only if test is succeeded\");
 	}
 	
 
 >It is <i>not</i> required to notify with success,
  if test function doesn't notify on failure the test is considered as successfull.

 --------------------------------------------
 "
by( "Lis" )
see( `class AsyncTestExecutor`, `package herd.asynctest.match` )
shared interface AsyncTestContext
{
	
	"Starts the testing. To be called by test function before running the test, but after initialization."
	shared formal void start();
	
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete (
		"Optional title which is added to test variant name only if test is succeeded."
		String title = ""
	);
	
	
	"Succeeds the test with the given `message`."
	shared formal void succeed (
		"Success message." String message,
		"`True` if test to be completed and `false` to continue testing."
		Boolean complete = false
	);
	
	
	"Fails the test if `val` doesn't match `matcher` or succeeds the test otherwise."
	see( `package herd.asynctest.match` )
	shared formal void assertThat<Value> (
		"Value to be matched."
		Value val,
		"Performs checking."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"`True` if test to be completed at failure and `false` to continue testing disregard failure occurrence."
		Boolean complete = false
	);
	
	
	"Fails the test with either `AssertionError` or `Exception`."
	shared formal void fail (
		"Reason fails this test."
		Throwable reason,
		"Optional title to be shown within test name."
		String title = "",
		"`True` if test to be completed and `false`."
		Boolean complete = false
	);
	
	
	"Aborts the test, which means that some test conditions are not met."
	shared formal void abort (
		"Optional error of the aborting."
		Throwable? reason = null,
		"Optional title to be shown within test name."
		String title = "",
		"`True` if test to be completed and `false` to continue testing."
		Boolean complete = false
	);
	
	"Aborts the test if `val` doesn't match `matcher`."
	see( `package herd.asynctest.match` )
	shared formal void assumeThat<Value> (
		"Value to be matched."
		Value val,
		"Performs checking."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"`True` if test to be completed at failure and `false` to continue testing disregard failure occurrence."
		Boolean complete = false
	);
	
}

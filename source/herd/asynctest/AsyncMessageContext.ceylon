

"Base interface to push test messages to.  
 The interface is mainly used by test runners [[herd.asynctest.runner::AsyncTestRunner]].  
 Test function receives derived interface [[AsyncTestContext]]."
since( "0.6.0" ) by( "Lis" )
shared interface AsyncMessageContext {
	
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete (
		"Optional title which is added to test variant name only if test is succeeded."
		String title = ""
	);
	
	
	"Succeeds the test with the given `message`."
	shared formal void succeed( "Success message." String message );
	
	
	"Fails the test with either `AssertionError` or `Exception`."
	shared formal void fail (
		"Reason fails this test or a function which throws either `AssertionError` or `Exception`.
		 If the function doesn't throw no any message is reported."
		Throwable | Anything() exceptionSource,
		"Optional title to be shown within test name."
		String title = ""
	);
	
}

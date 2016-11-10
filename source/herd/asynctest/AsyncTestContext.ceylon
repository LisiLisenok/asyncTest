import herd.asynctest.match {

	Matcher,
	MatchResult
}
import ceylon.promise {

	Promise
}

"
 Provides interaction with asynchronous test executor.
 
 General test procedure within test function is:
 
 1. Perform the testing. Notify test executor on failures or successes.
    Several notifications are allowed. Each failure or success notification is represented as test variant.
 2. Notify test executor on test procedure completion (call [[AsyncTestContext.complete]]).
    This step is nesseccary to continue testing with next execution
    since test executor blocks execution thread until [[AsyncTestContext.complete]] is called.
 
 	
 Example of tested function:
 	test async
 	void doTesting(AsyncTestContext context) {
 		// perform test procedure and notify about fails, if no fails notified test is considered successfull
 		context.fail(Exception(\"exception\"), \"some exception\");
 		context.fail(AssertionError( \"assert\"), \"some assert\");
 		context.assertThat(true, IsFalse(), \"to be \`false\`\");
 		
 		// complete testing
 		context.complete(\"title which is added to test variant name only if test is succeeded\");
 	}
 
 
 > It is _not_ required to notify with success,
   if test function doesn't notify on failure the test is considered as successfull.

 
 ### Promises
 
 [[assertThat]] and [[assertThatException]] accept `ceylon.promise::Promise`
 to perform matching operation when actual value is available. `Promise` returned by these methods
 can be used to complete testing. Example:
 
 		context.assertThat (
 			promiseOnActualValue,
 			matchingOperation
 		).onComplete((MatchResult|Throwable result) => context.complete());
 
 
 > If `value` is passed to [[assertThat]] or [[assertThatException]] methods the matching operation is performed immediately
   and methods return already fulfilled promise.
 
 --------------------------------------------
 "
see( `class AsyncTestExecutor`, `package herd.asynctest.match` )
since( "0.0.1" ) by( "Lis" )
shared interface AsyncTestContext
{
	"Completes the testing. To be called by test function when testing is completed.
	 This wakes up test thread and allows to continue testing and store results."
	shared formal void complete (
		"Optional title which is added to test variant name only if test is succeeded."
		String title = ""
	);
	
	
	"Succeeds the test with the given `message`."
	shared formal void succeed( "Success message." String message );
	
	
	"Fails the test if [[source]] doesn't match [[matcher]] or succeeds the test otherwise.  
	 Returns `promise` resolved with results of the matching.  
	 If value source function throws or promise rejects corresponding failure is reported
	 and returned promise is rejected with the failure."
	see( `package herd.asynctest.match`, `function assertThatListener` )
	since( "0.4.0" )
	shared formal Promise<MatchResult> assertThat<Value> (
		"Value source: value itself, function returned value or promise on value to be matched."
		Value | Value() | Promise<Value> source,
		"Verifies if the value matches expectations."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	);
	
	
	"Similar to [[assertThat]] but instantiates a listener on value to be matched."
	see( `package herd.asynctest.match`, `function assertThat` )
	since( "0.6.0" )
	shared default Promise<MatchResult> assertThatListener<Value> (
		"Verifies if the value matches expectations."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	)
	 ( "Value source: value itself, function returned value or promise on value to be matched."
			Value | Value() | Promise<Value> source )
		=> assertThat<Value>( source, matcher, title, reportSuccess );
	
	
	"Fails the test with either `AssertionError` or `Exception`."
	shared formal void fail (
		"Reason fails this test or a function which throws either `AssertionError` or `Exception`.
		 If the function doesn't throw no any message is reported."
		Throwable | Anything() exceptionSource,
		"Optional title to be shown within test name."
		String title = ""
	);
	
	
	"Fails the test if a given exception doesn't match [[matcher]] or succeeds the test otherwise.  
	 Returns `promise` resolved with results of the matching.    
	 The exception source may be an exception itself, function throwing an exception
	 or promise to be rejected with an exception."
	see( `package herd.asynctest.match`, `function assertThatExceptionListener` )
	since( "0.6.0" )
	shared formal Promise<MatchResult> assertThatException (
		"Exception source: exception itself, function throwing exception or promise to be rejected."
		Throwable | Anything() | Promise<Anything> source,
		"Verifies if the exception matches expectations."
		Matcher<Throwable> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	);
	
	
	"Similar to [[assertThatException]] but instantiates a listener on exception to be matched."
	see( `package herd.asynctest.match`, `function assertThat` )
	since( "0.6.0" )
	shared default Promise<MatchResult> assertThatExceptionListener (
		"Verifies if the exception matches expectations."
		Matcher<Throwable> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	)
	( "Exception source: exception itself, function throwing exception or promise to be rejected."
		Throwable | Anything() | Promise<Anything> source )
			=> assertThatException( source, matcher, title, reportSuccess );
	
}

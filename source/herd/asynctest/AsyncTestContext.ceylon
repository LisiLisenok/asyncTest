import herd.asynctest.match {

	Matcher
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
 "
see( `class AsyncTestExecutor`, `package herd.asynctest.match` )
since( "0.0.1" ) by( "Lis" )
shared interface AsyncTestContext
{
	
	"Completes the testing. To be called by the test function when testing is completed.
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
	
	
	"Verifies matcher." since( "0.6.0" )
	void verifyMatcher<Value> (
		"Value source: value itself or function returned value to be matched."
		Value source,
		"Verifies if the value matches expectations."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title,
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess
	) {
		value m = matcher.match( source );
		if ( m.accepted ) {
			if ( reportSuccess ) {
				succeed( if ( title.empty ) then m.string else title + " - " + m.string );
			}
		}
		else {
			fail (
				AssertionError( m.string ),
				if ( title.empty ) then m.string else title + " - " + m.string
			);
		}
		
	}
	
	"Fails the test if `source` doesn't match `matcher` or succeeds the test otherwise.  
	 If value source function throws corresponding failure is reported."
	see( `package herd.asynctest.match`, `function assertThatListener` )
	since( "0.4.0" )
	shared default void assertThat<Value> (
		"Value source: value itself or function returned value to be matched."
		Value | Value() source,
		"Verifies if the value matches expectations."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures.  
		 Default is `false`."
		Boolean reportSuccess = false
	) {
		try { 
			if ( is Value() source ) {
				verifyMatcher( source(), matcher, title, reportSuccess );
			}
			else {
				verifyMatcher( source, matcher, title, reportSuccess );
			}
		}
		catch ( Throwable err ) {
			fail( err, title );
		}
	}
	
	
	"Similar to [[assertThat]] but instantiates a listener on value to be matched."
	see( `package herd.asynctest.match`, `function assertThat` )
	since( "0.6.0" )
	shared default void assertThatListener<Value> (
		"Verifies if the value matches expectations."
		Matcher<Value> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	)
	 ( "Value source: value itself or function returned value to be matched."
			Value | Value() source )
		=> assertThat<Value>( source, matcher, title, reportSuccess );
	
	
	"Creates a function which throws and to be checked on exception with [[assertThat]]."
	since( "0.6.0" )
	Throwable toThrow( Throwable | Anything() source )() {
		if ( is Anything() source ) {
			try { source(); }
			catch ( Throwable err ) { return err; }
			throw AssertionError( "assertion failed: exception was not thrown." );
		}
		else {
			return source;
		}
	}
	
	"Fails the test if a given exception doesn't match `matcher` or succeeds the test otherwise.  
	 The exception source may be an exception itself or function throwing an exception."
	see( `package herd.asynctest.match`, `function assertThatExceptionListener` )
	since( "0.6.0" )
	shared default void assertThatException (
		"Exception source: exception itself or function throwing exception."
		Throwable | Anything() source,
		"Verifies if the exception matches expectations."
		Matcher<Throwable> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	) => assertThat<Throwable>( toThrow( source ), matcher, title, reportSuccess );
	
	
	"Similar to [[assertThatException]] but instantiates a listener on exception to be matched."
	see( `package herd.asynctest.match`, `function assertThat` )
	since( "0.6.0" )
	shared default void assertThatExceptionListener (
		"Verifies if the exception matches expectations."
		Matcher<Throwable> matcher,
		"Optional title to be shown within test name."
		String title = "",
		"If `true` reports on failures and successes.
		 Otherwise reportes only on failures."
		Boolean reportSuccess = false
	)
	( "Exception source: exception itself or function throwing exception."
		Throwable | Anything() source )
			=> assertThatException( source, matcher, title, reportSuccess );
	
}

import ceylon.collection {
	ArrayList
}
import ceylon.language.meta.model {
	IncompatibleTypeException,
	InvocationException
}
import ceylon.test {
	TestState
}
import ceylon.test.engine {
	TestAbortedException,
	TestSkippedException
}

import java.util.concurrent.locks {
	ReentrantLock
}
import herd.asynctest.match {

	Matcher,
	MatchResult
}
import ceylon.promise {

	Promise,
	Deferred
}
import herd.asynctest.internal {

	ContextThreadGroup
}
import java.lang {

	Thread
}


"Performs a one test execution and provides tet function with test context.  
 Rule: one tester - one test function!"
since( "0.0.1" ) by( "Lis" )
class Tester (
	"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	ContextThreadGroup group
)
		extends ContextBase() satisfies AsyncTestContext
{
	
	//"Group to run test function, is used in order to interrupt for timeout and treat uncaught exceptions."
	//ContextThreadGroup group = ContextThreadGroup( "asyncTester" );

	"outputs locking"
	ReentrantLock outputLocker = ReentrantLock();
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	variable TestState totalState = TestState.skipped;
	
	
	shared actual Promise<MatchResult> assertThat<Value> (
		Value|Value()|Promise<Value> source, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		if ( running.get() ) {
			Deferred<MatchResult> ret = Deferred<MatchResult>();
			if ( is Promise<Value> source ) {
				source.completed (
					( Value source ) {
						if ( running.get() ) { fillMatcher( ret, source, matcher, title, reportSuccess ); }
						else { ret.reject( TestContextHasBeenStopped() ); }
					},
					( Throwable err ) {
						addOutput( TestState.failure, err, title );
						ret.reject( err );
					}
				);
			}
			else if ( is Value() source ) {
				if ( running.get() ) {
					try {
						Value v = source();
						fillMatcher( ret, v, matcher, title, reportSuccess );
					}
					catch ( Throwable err ) {
						addOutput( TestState.failure, err, title );
						ret.reject( err );
					}
				}
				else {
					ret.reject( TestContextHasBeenStopped() );
				}
			}
			else {
				if ( running.get() ) { fillMatcher( ret, source, matcher, title, reportSuccess ); }
				else { ret.reject( TestContextHasBeenStopped() ); }
			}
			return ret.promise;
		}
		else {
			return getContextStoppedRejectedPromise();
		}
	}
		
	shared actual Promise<MatchResult> assertThatException (
		Throwable|Anything()|Promise<Anything> source, Matcher<Throwable> matcher, String title, Boolean reportSuccess
	) {
		if ( running.get() ) {
			Deferred<MatchResult> ret = Deferred<MatchResult>();
			if ( is Promise<Anything> source ) {
				source.completed (
					( Anything source ) {
						if ( running.get() ) {
							value err = AssertionError( "assertion failed: exception was not thrown." );
							addOutput( TestState.failure, err, title );
							ret.reject( err );
						}
						else {
							ret.reject( TestContextHasBeenStopped() );
						}
					},
					( Throwable err ) {
						if ( running.get() ) { fillMatcher( ret, err, matcher, title, reportSuccess ); }
						else { ret.reject( TestContextHasBeenStopped() ); }
					}
				);
			}
			else if ( is Anything() source ) {
				if ( running.get() ) {
					try {
						source();
						value err = AssertionError( "assertion failed: exception was not thrown." );
						addOutput( TestState.failure, err, title );
						ret.reject( err );
					}
					catch ( Throwable err ) {
						fillMatcher( ret, err, matcher, title, reportSuccess );
						ret.reject( err );
					}
				}
				else {
					ret.reject( TestContextHasBeenStopped() );
				}
			}
			else {
				if ( running.get() ) { fillMatcher( ret, source, matcher, title, reportSuccess ); }
				else { ret.reject( TestContextHasBeenStopped() ); }
			}
			return ret.promise;
		}
		else {
			return getContextStoppedRejectedPromise();
		}
	}
		
	shared actual void complete( String title ) {
		if ( running.compareAndSet( true, false ) ) {
			if ( outputs.empty ) {
				if ( title.empty ) { totalState = TestState.success; }
				else { addOutput( TestState.success, null, title ); }
			}
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
			signal();
		}
	}
		
	shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
		if ( running.get() ) {
			if ( is Throwable exceptionSource ) {
				failWithError( exceptionSource, title );
			}
			else {
				try { exceptionSource(); }
				catch ( Throwable err ) { failWithError( err, title ); }
			}
		}
	}
		
	shared actual void succeed( String message ) {
		if ( running.get() ) {
			addOutput( TestState.success, null, message );
		}
	}
	
	
	"Adds new output to `outputs`"
	void addOutput( TestState state, Throwable? error, String title ) {
		Integer elapsed = if ( startTime > 0 ) then system.milliseconds - startTime else 0;
		outputLocker.lock();
		try {
			outputs.add( TestOutput( state, error, elapsed, title ) );
			if ( totalState < state ) { totalState = state; }
		}
		finally { outputLocker.unlock(); }
	}
	
	"Fails the test with either `Exception` or `AssertionError`."
	void failWithError( Throwable reason, String title ) {
		if ( is AssertionError reason ) {
			addOutput( TestState.failure, reason, title );
		}
		else {
			addOutput( TestState.error, reason, title );
		}
	}
	
	"Fails and completes the test with uncaught exception from some execution thread."
	void failWithUncaughtException( Thread t, Throwable e ) {
		fail( e, "uncaught exception in child thread." );
		complete();
	}
	
	"Fills matcher with value, reports and returns results."
	void fillMatcher<Value> (
		Deferred<MatchResult> deferred, Value val, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		try {
			value m = matcher.match( val );
			if ( m.accepted ) {
				if ( reportSuccess ) {
					addOutput (
						TestState.success, null,
						if ( title.empty ) then m.string else title + " - " + m.string
					);
				}
			}
			else {
				addOutput (
					TestState.failure, AssertionError( m.string ),
					if ( title.empty ) then m.string else title + " - " + m.string
				);
			}
			deferred.fulfill( m );
		}
		catch ( Throwable err ) {
			addOutput( TestState.failure, err, title );
			deferred.reject( err );
		}
	}

	
	"Runs test function."
	void execute( Anything(AsyncTestContext) testFunction, String functionTitle )() {
		startTime = system.milliseconds;
		completeTime = startTime; 
		try {
			// invoke test function
			testFunction( this );
		}
		catch ( Throwable err ) {
			if ( err is TestSkippedException ) {
				if ( running.get() ) {
					addOutput( TestState.skipped, err, if ( functionTitle.empty ) then "skipped with exception"
						else "``functionTitle`` skipped with exception" );
				}
			}
			else if ( err is TestAbortedException ) {
				if ( running.get() ) {
					addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "aborted with exception"
						else "``functionTitle`` aborted with exception");
				}
			}
			else if ( err is IncompatibleTypeException | InvocationException ) {
				if ( running.get() ) {
					addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "incompatible invocation"
						else "incompatible invocation ``functionTitle``" );
				}
			}
			else {
				if ( running.get() ) {
					fail( err, if ( functionTitle.empty ) then "failed with exception"
						else  "``functionTitle`` failed with exception" );
				}
			}
			complete( "" );
		}
		// await test completion
		await();
	}


	"Returns output from the test."
	shared TestVariantResult run( TestFunction testFunction ) {
		// execute the test
		if ( !group.execute (
			failWithUncaughtException, testFunction.timeOutMilliseconds,
			execute( testFunction.run, testFunction.functionTitle ) )
		) {
			// timeout!
			stop();
			value excep = TimeOutException( testFunction.timeOutMilliseconds );
			addOutput( TestState.error, excep,
				if ( testFunction.functionTitle.empty ) then excep.message
				else "time out of ``testFunction.functionTitle`` execution"
			);
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
		}
		// return results
		outputLocker.lock();
		try {
			value ret = outputs.sequence();
			outputs.clear();
			return TestVariantResult( ret, completeTime - startTime, totalState );
		}
		finally { outputLocker.unlock(); }
	}
	
}

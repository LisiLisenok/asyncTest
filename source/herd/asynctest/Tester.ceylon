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


"Performs a one test execution."
since( "0.0.1" ) by( "Lis" )
class Tester()
{
	
	"Thread group the test is performed using."
	object group extends ContextThreadGroup<AsyncTestContext>( "asyncTester" ) {
		shared actual void stopWithError( AsyncTestContext c, Throwable err ) {
			c.fail( err, "uncaught exception in child thread." );
			c.complete();
		}
	}
	

	"outputs locking"
	ReentrantLock outputLocker = ReentrantLock();
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	
	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	variable TestState totalState = TestState.skipped;
	
	
	"Provides a test context to tested function.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext() extends ContextBase() satisfies AsyncTestContext {
		
		void failWithError( Throwable reason, String title ) {
			if ( is AssertionError reason ) {
				addOutput( TestState.failure, reason, title );
			}
			else {
				addOutput( TestState.error, reason, title );
			}
		}
		
		
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
	void execute( Anything(AsyncTestContext) testFunction, String functionTitle, InternalContext context )() {
		startTime = system.milliseconds;
		completeTime = startTime; 
		try {
			// invoke test function
			testFunction( context );
		}
		catch ( Throwable err ) {
			if ( err is TestSkippedException ) {
				if ( context.running.get() ) {
					addOutput( TestState.skipped, err, if ( functionTitle.empty ) then "skipped with exception"
						else "``functionTitle`` skipped with exception" );
				}
			}
			else if ( err is TestAbortedException ) {
				if ( context.running.get() ) {
					addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "aborted with exception"
						else "``functionTitle`` aborted with exception");
				}
			}
			else if ( err is IncompatibleTypeException | InvocationException ) {
				if ( context.running.get() ) {
					addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "incompatible invocation"
						else "incompatible invocation ``functionTitle``" );
				}
			}
			else {
				if ( context.running.get() ) {
					context.fail( err, if ( functionTitle.empty ) then "failed with exception"
						else  "``functionTitle`` failed with exception" );
				}
			}
			context.complete( "" );
		}
		context.await();
	}

	"Runs test function on separated thread and looks for timeout."
	void executeOnSeparatedThread (
		TestFunction testFunction
	) {
		// thread to execute test function
		InternalContext context = InternalContext();
		if ( !group.execute (
				context, testFunction.timeOutMilliseconds,
				execute( testFunction.run, testFunction.functionTitle, context )
			)
		) {
			// timeout!
			context.stop();
			value excep = TimeOutException( testFunction.timeOutMilliseconds );
			addOutput( TestState.error, excep,
				if ( testFunction.functionTitle.empty ) then excep.message
				else "time out of ``testFunction.functionTitle`` execution"
			);
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
		}
	}

	"Returns output from the test."
	shared TestVariantResult run( TestFunction testFunction ) {
		// execute the test
		executeOnSeparatedThread( testFunction );
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

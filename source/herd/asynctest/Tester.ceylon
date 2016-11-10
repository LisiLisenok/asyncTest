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

import java.util.concurrent.atomic {
	AtomicBoolean
}
import java.util.concurrent.locks {
	ReentrantLock,
	Condition
}
import herd.asynctest.match {

	Matcher,
	MatchResult
}
import ceylon.promise {

	Promise,
	Deferred
}
import java.lang {

	ThreadGroup,
	Thread,
	ThreadDeath
}
import herd.asynctest.internal {

	ExecutionThread,
	LatchWaiter
}


"Performs a one test execution."
since( "0.0.1" ) by( "Lis" )
class Tester()
{
	
	"Thread group the test is performed using."
	object group extends ThreadGroup( "asyncTester" ) {
		variable AsyncTestContext? context = null;
		
		shared void setContext( AsyncTestContext c ) {
			context = c;
		}
		
		shared void resetContext() {
			context = null;
		}
		
		shared actual void uncaughtException( Thread t, Throwable e ) {
			if ( is ThreadDeath e ) {
				super.uncaughtException( t, e );
			}
			else {
				if ( exists c = context ) {
					c.fail( e, "uncaught exception in child thread." );
					c.complete();
					resetContext();
				}
				else {
					super.uncaughtException( t, e );
				}
			}
		}
	}
	
	"`true` if currently run"
	AtomicBoolean running = AtomicBoolean( false );
	"locker behind this running"
	ReentrantLock locker = ReentrantLock();
	"condition behind this running"
	Condition condition = locker.newCondition();


	"outputs locking"
	ReentrantLock outputLocker = ReentrantLock();
	"storage for reports"
	ArrayList<TestOutput> outputs = ArrayList<TestOutput>();

	
	variable Integer startTime = 0;
	variable Integer completeTime = 0; 
	variable TestState totalState = TestState.skipped;
	
	
	"Provides a test context to tested function.  
	 Delegates reporting to `outer` until `stop` called."
	class InternalContext() satisfies AsyncTestContext {
		AtomicBoolean running = AtomicBoolean( true );
		
		"Stops the context - not any message will be sent."
		shared void stop() { running.set( false ); }
		
		"Adds output if not stopped."
		shared void addOutput( TestState state, Throwable? error, String title ) {
			if ( running.get() ) {
				outer.addOutput( state, error, title );
			}
		}
		
		shared actual Promise<MatchResult> assertThat<Value> (
			Value|Value()|Promise<Value> source, Matcher<Value> matcher, String title, Boolean reportSuccess
		) {
			if ( running.get() ) {
				return outer.assertThat<Value>(source, matcher, title, reportSuccess );
			}
			Deferred<MatchResult> def = Deferred<MatchResult>();
			def.reject( TestContextHasBeenStopped() );
			return def.promise;
		}
		
		shared actual Promise<MatchResult> assertThatException (
			Throwable|Anything()|Promise<Anything> source, Matcher<Throwable> matcher, String title, Boolean reportSuccess
		) {
			if ( running.get() ) {
				return outer.assertThatException(source, matcher, title, reportSuccess );
			}
			Deferred<MatchResult> def = Deferred<MatchResult>();
			def.reject( TestContextHasBeenStopped() );
			return def.promise;
		}
		
		shared actual void complete( String title ) {
			if ( running.compareAndSet( true, false ) ) {
				outer.complete( title );
			}
		}
		
		shared actual void fail( Throwable|Anything() exceptionSource, String title ) {
			if ( running.get() ) {
				outer.fail( exceptionSource, title );
			}
		}
		
		shared actual void succeed( String message ) {
			if ( running.get() ) {
				outer.succeed( message );
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
	
	void failWithError( Throwable reason, String title ) {
		if ( is AssertionError reason ) {
			addOutput( TestState.failure, reason, title );
		}
		else {
			addOutput( TestState.error, reason, title );
		}
	}

	
	void complete( String title ) {
		if ( running.compareAndSet( true, false ) ) {
			if ( outputs.empty ) {
				if ( title.empty ) { totalState = TestState.success; }
				else { addOutput( TestState.success, null, title ); }
			}
			completeTime = system.milliseconds;
			if ( startTime == 0 ) { startTime = completeTime; }
			if ( locker.tryLock() ) {
				try { condition.signal(); }
				finally { locker.unlock(); }
			}
		}
	}


	void succeed( String message ) {
		if ( running.get() ) {
			addOutput( TestState.success, null, message );
		}
	}

	Promise<MatchResult> assertThat<Value> (
		Value | Value() | Promise<Value> source, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		Deferred<MatchResult> ret = Deferred<MatchResult>();
		if ( is Promise<Value> source ) {
			source.completed (
				( Value source ) {
					if ( running.get() ) { fillMatcher( ret, source, matcher, title, reportSuccess ); }
					else { ret.reject( TestContextHasBeenStopped() ); }
				},
				( Throwable err ) {
					if ( running.get() ) { addOutput( TestState.failure, err, title ); }
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

	
	void fail( Throwable | Anything() exceptionSource, String title ) {
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
	
	
	Promise<MatchResult> assertThatException (
		Throwable | Anything() | Promise<Anything> source, Matcher<Throwable> matcher, String title, Boolean reportSuccess
	) {
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
	
	
	"Runs test function."
	void execute( Anything(AsyncTestContext) testFunction, String functionTitle, InternalContext context ) {
		startTime = system.milliseconds;
		completeTime = startTime; 
		try {
			// invoke test function
			testFunction( context );
		}
		catch ( Throwable err ) {
			if ( err is TestSkippedException ) {
				context.addOutput( TestState.skipped, err, if ( functionTitle.empty ) then "skipped with exception"
					else "``functionTitle`` skipped with exception" );
			}
			else if ( err is TestAbortedException ) {
				context.addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "aborted with exception"
					else "``functionTitle`` aborted with exception");
			}
			else if ( err is IncompatibleTypeException | InvocationException ) {
				context.addOutput( TestState.aborted, err, if ( functionTitle.empty ) then "incompatible invocation"
					else "incompatible invocation ``functionTitle``" );
			}
			else {
				context.fail( err, if ( functionTitle.empty ) then "failed with exception"
					else  "``functionTitle`` failed with exception" );
			}
			context.complete( "" );
		}
		if ( running.get() ) {
			locker.lock();
			try { condition.await(); }
			finally { locker.unlock(); }
		}
	}

	"Runs test function isseparated thread andlooks for timeout."
	void executeInSeparatedThread (
		TestFunction testFunction
	) {
		// thread to execute test function
		LatchWaiter latch = LatchWaiter( 1 );
		InternalContext context = InternalContext();
		group.setContext( context );
		ExecutionThread thr = ExecutionThread (
			group, "asyncTesterThread",
			() {
				try { execute( testFunction.run, testFunction.functionTitle, context ); }
				catch ( Throwable err ) {
					context.fail( err, if ( testFunction.functionTitle.empty ) then "failed with exception"
						else  "``testFunction.functionTitle`` failed with exception" );
				}
				finally {
					context.stop();
					latch.countDown();
				}
			}
		);
		
		thr.start();
		
		if ( !latch.awaitUntil( testFunction.timeOutMilliseconds ) ) {
			// timeout!
			context.stop();
			group.interrupt();
			value excep = TimeOutException( testFunction.timeOutMilliseconds );
			addOutput( TestState.error, excep,
				if ( testFunction.functionTitle.empty ) then excep.message
				else "time out of ``testFunction.functionTitle`` execution"
			);
			complete( "" );
		}
		group.resetContext();
	}

	"Returns output from the test."
	shared TestVariantResult run( TestFunction testFunction ) {
		if ( running.compareAndSet( false, true ) ) {
			// execute the test
			executeInSeparatedThread( testFunction );
			// return results
			outputLocker.lock();
			try {
				value ret = outputs.sequence();
				outputs.clear();
				return TestVariantResult( ret, completeTime - startTime, totalState );
			}
			finally { outputLocker.unlock(); }
		}
		else {
			return TestVariantResult( [], 0, totalState );
		}
	}
	
}

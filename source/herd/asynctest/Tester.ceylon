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


"Performs a one test execution."
since( "0.0.1" )
by( "Lis" )
class Tester() satisfies AsyncTestContext
{
	
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
			
	
	"adds new output to `outputs`"
	void addOutput(	TestState state, Throwable? error, String title ) {
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
						TestState.success,
						null,
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

	
	shared actual void complete( String title ) {
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


	shared actual void succeed( String message ) {
		if ( running.get() ) {
			addOutput( TestState.success, null, message );
		}
	}

	shared actual Promise<MatchResult> assertThat<Value> (
		Value | Value() | Promise<Value> source, Matcher<Value> matcher, String title, Boolean reportSuccess
	) {
		Deferred<MatchResult> ret = Deferred<MatchResult>();
		if ( is Promise<Value> source ) {
			source.completed (
				( Value source ) {
					if ( running.get() ) {
						fillMatcher( ret, source, matcher, title, reportSuccess );
					}
				},
				( Throwable err ) {
					if ( running.get() ) {
						addOutput( TestState.failure, err, title );
						ret.reject( err );
					}
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
		}
		else {
			if ( running.get() ) {
				fillMatcher( ret, source, matcher, title, reportSuccess );
			}
		}
		return ret.promise;
	}

	
	shared actual void fail( Throwable | Anything() exceptionSource, String title ) {
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
	
	
	shared actual Promise<MatchResult> assertThatException (
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
				},
				( Throwable err ) {
					if ( running.get() ) {
						fillMatcher( ret, err, matcher, title, reportSuccess );
					}
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
				}
			}
		}
		else {
			if ( running.get() ) {
				fillMatcher( ret, source, matcher, title, reportSuccess );
			}
		}
		return ret.promise;
	}

	
	"Returns output from the test."
	shared TestFunctionOutput run( Anything(AsyncTestContext) testFunction ) {
		if ( running.compareAndSet( false, true ) ) {
			locker.lock();
			startTime = system.milliseconds;
			completeTime = startTime; 
			try {
				// invoke test function
				testFunction( this );
				if ( running.get() ) { condition.await(); }
			}
			catch ( Throwable err ) {
				if ( err is TestSkippedException ) {
					addOutput( TestState.skipped, err, "skipped with exception" );
				}
				else if ( err is TestAbortedException ) {
					addOutput( TestState.aborted, err, "aborted with exception" );
				}
				else if  ( err is IncompatibleTypeException | InvocationException ) {
					addOutput( TestState.aborted, err, "incompatible invocation" );
				}
				else {
					fail( err, "failed with exception" );
				}
				complete();
			}
			finally {
				locker.unlock();
			}
			
			outputLocker.lock();
			try {
				value ret = outputs.sequence();
				outputs.clear();
				return TestFunctionOutput( ret, completeTime - startTime, totalState );
			}
			finally { outputLocker.unlock(); }
		}
		else {
			return TestFunctionOutput( [], 0, totalState );
		}
	}
	
}
